# Manage puppet configuration. See README.md for more details.
class puppetdb::master::config (
  $puppetdb_server             = $::fqdn,
  $puppetdb_port               = defined(Class['puppetdb']) ? {
    true    => $::puppetdb::disable_ssl ? {
      true => 8080,
      default => 8081,
    },
    default => 8081,
  },
  $puppetdb_disable_ssl        = defined(Class['puppetdb']) ? {
    true    => $::puppetdb::disable_ssl,
    default => false,
  },
  $masterless                  = $puppetdb::params::masterless,
  $puppetdb_soft_write_failure = false,
  $manage_routes               = true,
  $manage_storeconfigs         = true,
  $manage_report_processor     = false,
  $manage_config               = true,
  $strict_validation           = true,
  $enable_reports              = false,
  $puppet_confdir              = $puppetdb::params::puppet_confdir,
  $puppet_conf                 = $puppetdb::params::puppet_conf,
  $terminus_package            = $puppetdb::params::terminus_package,
  $puppet_service_name         = $puppetdb::params::puppet_service_name,
  $puppetdb_startup_timeout    = $puppetdb::params::puppetdb_startup_timeout,
  $test_url                    = $puppetdb::params::test_url,
  $restart_puppet              = true,
) inherits puppetdb::params {

  # **WARNING**: Ugly hack to work around a yum bug with metadata parsing. This
  # should not be copied, replicated or even looked at. In short, never rename
  # your packages...
  #
  # With `yum` we can't have the termini package override the terminus package
  # because that would prevent users from installing v2.3 of the terminus in
  # PC1. We tried using a dummy terminus-3 metadata package which pulled in
  # termini-3.latest as a dependency and put a requires terminus >= 3, <4. The
  # idea was that doing `yum install puppetdb-termini-3.x.y-1.el7` would pull up
  # the terminus package to the dummy 3 version, but `yum` has a bug which
  # requires that both the dummy package and termini be installed in the same
  # transaction, i.e. `yum install puppetdb-termini-3.x.y-1.el7
  # puppetdb-terminus-3` which is impossible to do via Puppet.
  #
  # This will orphan some old terminus files (from pre-puppet-agent, i.e. puppet
  # 3.x) that are orphaned as part of the Puppet 3 to Puppet 4 upgrade anyways
  # and some of the new terminus files temporarily. If this exec fails all you
  # need to do is reinstall whatever 2.3 version of the terminus was already
  # installed to revert the change.
  if !($puppetdb::params::puppetdb_version in ['present','absent'])
  and versioncmp($puppetdb::params::puppetdb_version, '3.0.0') >= 0
  and $::osfamily in ['RedHat','Suse'] {
    exec { 'Remove puppetdb-terminus metadata for upgrade':
      command => 'rpm -e --justdb puppetdb-terminus',
      path    => '/sbin/:/bin/',
      onlyif  => 'rpm -q puppetdb-terminus',
      before  => Package[$terminus_package],
    }
  }

  package { $terminus_package:
    ensure => $puppetdb::params::puppetdb_version,
  }

  if ($strict_validation) {

    # Validate the puppetdb connection.  If we can't connect to puppetdb then we
    # *must* not perform the other configuration steps, or else

    $conn_puppetdb_server = $manage_config ? {
      true    => $puppetdb_server,
      default => undef,
    }
    $conn_puppetdb_port = $manage_config ? {
      true    => $puppetdb_port,
      default => undef,
    }
    $conn_puppetdb_ssl = $puppetdb_disable_ssl ? {
      true    => false,
      default => true,
    }

    puppetdb_conn_validator { 'puppetdb_conn':
      puppetdb_server => $conn_puppetdb_server,
      puppetdb_port   => $conn_puppetdb_port,
      use_ssl         => $conn_puppetdb_ssl,
      timeout         => $puppetdb_startup_timeout,
      require         => Package[$terminus_package],
      test_url        => $test_url,
    }

    # This is a bit of puppet chicanery that allows us to create a
    # conditional dependency.  Basically, we're saying that "if the PuppetDB
    # service is being managed in this same catalog, it needs to come before
    # this validator."
    Service<|title == $puppetdb::params::puppetdb_service|> -> Puppetdb_conn_validator['puppetdb_conn']
  }

  # Conditionally manage the `routes.yaml` file.  Restart the puppet service
  # if changes are made.
  if ($manage_routes) {
    $routes_require = $strict_validation ? {
      true    => Puppetdb_conn_validator['puppetdb_conn'],
      default => Package[$terminus_package],
    }

    class { 'puppetdb::master::routes':
      puppet_confdir => $puppet_confdir,
      masterless     => $masterless,
      require        => $routes_require,
    }
  }

  # Conditionally manage the storeconfigs settings in `puppet.conf`.  We don't
  # need to trigger a restart of the puppet master service for this one, because
  # it polls it automatically.
  if ($manage_storeconfigs) {
    $storeconfigs_require = $strict_validation ? {
      true    => Puppetdb_conn_validator['puppetdb_conn'],
      default => Package[$terminus_package],
    }

    class { 'puppetdb::master::storeconfigs':
      puppet_conf => $puppet_conf,
      masterless  => $masterless,
      require     => $storeconfigs_require,
    }
  }

  # Conditionally manage the puppetdb report processor setting in `puppet.conf`.
  # We don't need to trigger a restart of the puppet master service for this one,
  # because it polls it automatically.
  if ($manage_report_processor) {
    $report_processor_require = $strict_validation ? {
      true    => Puppetdb_conn_validator['puppetdb_conn'],
      default => Package[$terminus_package],
    }

    class { 'puppetdb::master::report_processor':
      puppet_conf => $puppet_conf,
      masterless  => $masterless,
      enable      => $enable_reports,
      require     => $report_processor_require,
    }
  }

  if ($manage_config) {
    # Manage the `puppetdb.conf` file.  Restart the puppet service if changes
    # are made.
    $puppetdb_conf_require = $strict_validation ? {
      true    => Puppetdb_conn_validator['puppetdb_conn'],
      default => Package[$terminus_package],
    }

    class { 'puppetdb::master::puppetdb_conf':
      server             => $puppetdb_server,
      port               => $puppetdb_port,
      soft_write_failure => $puppetdb_soft_write_failure,
      puppet_confdir     => $puppet_confdir,
      legacy_terminus    => $puppetdb::params::terminus_package == 'puppetdb-terminus',
      require            => $puppetdb_conf_require,
    }
  }

  if ($restart_puppet) {
    # We will need to restart the puppet master service if certain config
    # files are changed, so here we make sure it's in the catalog.
    if ! defined(Service[$puppet_service_name]) {
      service { $puppet_service_name:
        ensure => running,
      }
    }

    if ($manage_config) {
      Class['puppetdb::master::puppetdb_conf'] ~> Service[$puppet_service_name]
    }

    if ($manage_routes) {
      Class['puppetdb::master::routes'] ~> Service[$puppet_service_name]
    }
  }

}
