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


  package { $terminus_package:
    ensure => $puppetdb::params::puppetdb_version,
  }

  if ($strict_validation) {

    # Validate the puppetdb connection.  If we can't connect to puppetdb then we
    # *must* not perform the other configuration steps, or else
    puppetdb_conn_validator { 'puppetdb_conn':
      puppetdb_server => $manage_config ? {
        true    => $puppetdb_server,
        default => undef,
      },
      puppetdb_port   => $manage_config ? {
        true    => $puppetdb_port,
        default => undef,
      },
      use_ssl         => $puppetdb_disable_ssl ? {
        true    => false,
        default => true,
      },
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
    class { 'puppetdb::master::routes':
      puppet_confdir => $puppet_confdir,
      masterless     => $masterless,
      require        => $strict_validation ? {
        true    => Puppetdb_conn_validator['puppetdb_conn'],
        default => Package[$terminus_package],
      },
    }
  }

  # Conditionally manage the storeconfigs settings in `puppet.conf`.  We don't
  # need to trigger a restart of the puppet master service for this one, because
  # it polls it automatically.
  if ($manage_storeconfigs) {
    class { 'puppetdb::master::storeconfigs':
      puppet_conf => $puppet_conf,
      masterless  => $masterless,
      require     => $strict_validation ? {
        true    => Puppetdb_conn_validator['puppetdb_conn'],
        default => Package[$terminus_package],
      },
    }
  }

  # Conditionally manage the puppetdb report processor setting in `puppet.conf`.
  # We don't need to trigger a restart of the puppet master service for this one,
  # because it polls it automatically.
  if ($manage_report_processor) {
    class { 'puppetdb::master::report_processor':
      puppet_conf => $puppet_conf,
      masterless  => $masterless,
      enable      => $enable_reports,
      require     => $strict_validation ? {
        true    => Puppetdb_conn_validator['puppetdb_conn'],
        default => Package[$terminus_package],
      },
    }
  }

  if ($manage_config) {
    # Manage the `puppetdb.conf` file.  Restart the puppet service if changes
    # are made.
    class { 'puppetdb::master::puppetdb_conf':
      server             => $puppetdb_server,
      port               => $puppetdb_port,
      soft_write_failure => $puppetdb_soft_write_failure,
      puppet_confdir     => $puppet_confdir,
      legacy_terminus    => $puppetdb::params::terminus_package == 'puppetdb-terminus',
      require            => $strict_validation ? {
        true    => Puppetdb_conn_validator['puppetdb_conn'],
        default => Package[$terminus_package],
      },
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
