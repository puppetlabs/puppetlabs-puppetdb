# @summary manage the puppet configuration on the primary
#
# @param puppetdb_server
#   The dns name or ip of the PuppetDB server. Defaults to the hostname of the
#   current node, i.e. `$::fqdn`.
#
# @param puppetdb_port
#   The port that the PuppetDB server is running on. Defaults to `8081`.
#
# @param puppetdb_disable_ssl
#   If true, use plain HTTP to talk to PuppetDB. Defaults to the value of
#   `disable_ssl` if PuppetDB is on the same server as the Puppet Master, or else
#   false. If you set this, you probably need to set `puppetdb_port` to match the HTTP
#   port of the PuppetDB.
#
# @param puppetdb_soft_write_failure
#   Boolean to fail in a soft manner if PuppetDB is not accessible for command
#   submission Defaults to `false`.
#
# @param manage_routes
#   If `true`, the module will overwrite the Puppet master's routes file to
#   configure it to use PuppetDB. Defaults to `true`.
#
# @param manage_storeconfigs
#   If `true`, the module will manage the Puppet master's storeconfig settings.
#   Defaults to `true`.
#
# @param manage_report_processor
#   If `true`, the module will manage the 'reports' field in the puppet.conf file to
#   enable or disable the PuppetDB report processor. Defaults to `false`.
#
# @param manage_config
#   If `true`, the module will store values from `puppetdb_server` and `puppetdb_port`
#   parameters in the PuppetDB configuration file. If `false`, an existing PuppetDB
#   configuration file will be used to retrieve server and port values.
#
# @param create_puppet_service_resource
#   If `true`, AND if `restart_puppet` is true, then the module will create a service
#   resource for `puppet_service_name` if it has not been defined. Defaults to `true`.
#   If you are already declaring the `puppet_service_name` service resource in another
#   part of your code, setting this to `false` will avoid creation of that service
#   resource by this module, avoiding potential duplicate resource errors.
#
# @param strict_validation
#   If `true`, the module will fail if PuppetDB is not reachable, otherwise it will
#   preconfigure PuppetDB without checking.
#
# @param enable_reports
#   Ignored unless `manage_report_processor` is `true`, in which case this setting
#   will determine whether or not the PuppetDB report processor is enabled (`true`)
#   or disabled (`false`) in the puppet.conf file.
#
# @param enable_storeconfigs
#   Ignored unless `manage_storeconfigs` is `true`, in which case this setting
#   will determine whether or not client configuration storage is enabled (`true`)
#   or disabled (`false`) in the puppet.conf file.
#
# @param puppet_confdir
#   Puppet's config directory. Defaults to `/etc/puppetlabs/puppet`.
#
# @param puppet_conf
#   Puppet's config file. Defaults to `${puppet_confdir}/puppet.conf`.
#
# @param masterless
#   A boolean switch to enable or disable the masterless setup of PuppetDB. Defaults
#   to `false`.
#
# @param terminus_package
#   Name of the package to use that represents the PuppetDB terminus code. Defaults
#   to `puppetdb-termini`, when `puppetdb_version` is set to `<= 2.3.x` the default
#   changes to `puppetdb-terminus`.
#
# @param puppet_service_name
#   Name of the service that represents Puppet. You can change this to `apache2` or
#   `httpd` depending on your operating system, if you plan on having Puppet run
#   using Apache/Passenger for example.
#
# @param puppetdb_startup_timeout
#   The maximum amount of time that the module should wait for PuppetDB to start up.
#   This is most important during the initial install of PuppetDB (defaults to 120
#   seconds).
#
# @param test_url
#   The URL to use for testing if the PuppetDB instance is running.
#
# @param restart_puppet
#   If `true`, the module will restart the Puppet master when PuppetDB configuration
#   files are changed by the module. Defaults to `true`. If set to `false`, you
#   must restart the service manually in order to pick up changes to the config
#   files (other than `puppet.conf`).
#
class puppetdb::master::config (
  Stdlib::Host                                       $puppetdb_server                = fact('networking.fqdn'),
  Variant[Stdlib::Port::User, Pattern[/\A[0-9]+\Z/]] $puppetdb_port                  = defined(Class['puppetdb']) ? {
    true    => $puppetdb::disable_ssl ? {
      true => 8080,
      default => 8081,
    },
    default => 8081,
  },
  Boolean                                            $puppetdb_disable_ssl           = defined(Class['puppetdb']) ? {
    true    => $puppetdb::disable_ssl,
    default => false,
  },
  Boolean                                            $masterless                     = $puppetdb::params::masterless,
  Boolean                                            $puppetdb_soft_write_failure    = false,
  Boolean                                            $manage_routes                  = true,
  Boolean                                            $manage_storeconfigs            = true,
  Boolean                                            $enable_storeconfigs            = true,
  Boolean                                            $manage_report_processor        = false,
  Boolean                                            $manage_config                  = true,
  Boolean                                            $create_puppet_service_resource = true,
  Boolean                                            $strict_validation              = true,
  Boolean                                            $enable_reports                 = false,
  Stdlib::Absolutepath                               $puppet_confdir                 = $puppetdb::params::puppet_confdir,
  Stdlib::Absolutepath                               $puppet_conf                    = $puppetdb::params::puppet_conf,
  String[1]                                          $terminus_package               = $puppetdb::params::terminus_package,
  String[1]                                          $puppet_service_name            = $puppetdb::params::puppet_service_name,
  Integer[0]                                         $puppetdb_startup_timeout       = $puppetdb::params::puppetdb_startup_timeout,
  String[1]                                          $test_url                       = $puppetdb::params::test_url,
  Boolean                                            $restart_puppet                 = true,
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
  and $facts['os']['family'] in ['RedHat','Suse'] {
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
      enable      => $enable_storeconfigs,
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
    # files are changed, so here we make sure it's in the catalog. This is
    # parse-order dependent and could prevent another part of the code from
    # declaring the service, so set $create_puppet_service_resource to false if you
    # are absolutely sure you're declaring Service[$puppet_service_name] in
    # some other way.
    if $create_puppet_service_resource and ! defined(Service[$puppet_service_name]) {
      service { $puppet_service_name:
        ensure => running,
        enable => true,
      }
    }

    if ($manage_config) {
      Class['puppetdb::master::puppetdb_conf'] ~> Service[$puppet_service_name]
    }

    if ($manage_routes) {
      Class['puppetdb::master::routes'] ~> Service[$puppet_service_name]
    }

    if ($manage_report_processor) {
      Class['puppetdb::master::report_processor'] ~> Service[$puppet_service_name]
    }
  }
}
