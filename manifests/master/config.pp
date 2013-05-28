# Class: puppetdb::master::config
#
# This class configures the puppet master to use puppetdb.  This includes installing
# all of the required master-specific puppetdb packages and managing or deploying
# the necessary config files (`puppet.conf`, `routes.yaml`, and `puppetdb.conf`).
#
# ***WARNING***: the default behavior of this module is to overwrite puppet's
#  `routes.yaml` file, to configure it to use puppetdb.  If you have any custom
#  settings in your `routes.yaml` file, you'll want to pass `false` for
#  the `manage_routes` parameter and you'll have to manage that file yourself.
#
# Parameters:
#   ['puppetdb_server'] - The dns name or ip of the puppetdb server
#                          (defaults to the certname of the current node)
#   ['puppetdb_port']   - The port that the puppetdb server is running on (defaults to 8081)
#   ['manage_routes']   - If true, the module will overwrite the puppet master's routes
#                         file to configure it to use puppetdb (defaults to true)
#   ['manage_storeconfigs'] - If true, the module will manage the puppet master's
#                         storeconfig settings (defaults to true)
#   ['manage_config']   - If true, the module will store values from puppetdb_server
#                         and puppetdb_port parameters in the puppetdb configuration file.
#                         If false, an existing puppetdb configuration file will be used
#                         to retrieve server and port values.
#   ['manage_report_processor'] - If true, the module will manage the 'reports' field
#                         in the puppet.conf file to enable or disable the puppetdb
#                         report processor.  Defaults to 'false'.
#   ['strict_validation'] - If true, the module will fail if puppetdb is not reachable,
#                         otherwise it will preconfigure puppetdb without checking.
#   ['enable_reports']  - Ignored unless 'manage_report_processor' is `true`, in which
#                         case this setting will determine whether or not the puppetdb
#                         report processor is enabled (`true`) or disabled (`false`) in
#                         the puppet.conf file.
#   ['puppet_confdir']  - Puppet's config directory; defaults to /etc/puppet
#   ['puppet_conf']     - Puppet's config file; defaults to /etc/puppet/puppet.conf
#   ['puppetdb_version']   - The version of the `puppetdb` package that should
#                         be installed.  You may specify an explicit version
#                         number, 'present', or 'latest'.  Defaults to
#                         'present'.
#   ['puppetdb_startup_timeout']  - The maximum amount of time that the module
#                         should wait for puppetdb to start up; this is most
#                         important during the initial install of puppetdb.
#                         Defaults to 15 seconds.
#   ['restart_puppet']  - If true, the module will restart the puppet master when
#                         necessary.  The default is 'true'.  If set to 'false',
#                         you must restart the service manually in order to pick
#                         up changes to the config files (other than `puppet.conf`).
#
# Actions:
# - Configures the puppet master to use puppetdb.
#
# Requires:
# - Inifile
#
# Sample Usage:
#   class { 'puppetdb::master::config':
#       puppetdb_server          => 'my.host.name',
#       puppetdb_port            => 8081,
#   }
#
# TODO: finish porting this to use params
#
class puppetdb::master::config(
  $puppetdb_server          = $::fqdn,
  $puppetdb_port            = 8081,
  $manage_routes            = true,
  $manage_storeconfigs      = true,
  $manage_report_processor  = false,
  $manage_config            = true,
  $strict_validation        = true,
  $enable_reports           = false,
  $puppet_confdir           = $puppetdb::params::puppet_confdir,
  $puppet_conf              = $puppetdb::params::puppet_conf,
  $puppetdb_version         = $puppetdb::params::puppetdb_version,
  $terminus_package         = $puppetdb::params::terminus_package,
  $puppet_service_name      = $puppetdb::params::puppet_service_name,
  $puppetdb_startup_timeout = $puppetdb::params::puppetdb_startup_timeout,
  $restart_puppet           = true
) inherits puppetdb::params {

  package { $terminus_package:
    ensure => $puppetdb_version,
  }

  if ($strict_validation) {
	  # Validate the puppetdb connection.  If we can't connect to puppetdb then we
	  # *must* not perform the other configuration steps, or else
	  puppetdb_conn_validator { 'puppetdb_conn':
	    puppetdb_server => $manage_config ? { true => $puppetdb_server, default => undef },
	    puppetdb_port   => $manage_config ? { true => $puppetdb_port, default => undef },
	    timeout         => $puppetdb_startup_timeout,
	    require         => Package[$terminus_package],
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
      require        => $strict_validation ? { true => Puppetdb_conn_validator['puppetdb_conn'], default => Package[$terminus_package] },
    }
  }

  # Conditionally manage the storeconfigs settings in `puppet.conf`.  We don't
  # need to trigger a restart of the puppet master service for this one, because
  # it polls it automatically.
  if ($manage_storeconfigs) {
    class { 'puppetdb::master::storeconfigs':
      puppet_conf => $puppet_conf,
      require     => $strict_validation ? { true => Puppetdb_conn_validator['puppetdb_conn'], default => Package[$terminus_package] },
    }
  }

  # Conditionally manage the puppetdb report processor setting in `puppet.conf`.
  # We don't need to trigger a restart of the puppet master service for this one,
  # because it polls it automatically.
  if ($manage_report_processor) {
    class { 'puppetdb::master::report_processor':
        puppet_conf => $puppet_conf,
        enable      => $enable_reports,
        require     => $strict_validation ? { true => Puppetdb_conn_validator['puppetdb_conn'], default => Package[$terminus_package] },
    }
  }

  if ($manage_config) {
	  # Manage the `puppetdb.conf` file.  Restart the puppet service if changes
	  # are made.
	  class { 'puppetdb::master::puppetdb_conf':
	    server         => $puppetdb_server,
	    port           => $puppetdb_port,
	    puppet_confdir => $puppet_confdir,
	    require        => $strict_validation ? { true => Puppetdb_conn_validator['puppetdb_conn'], default => Package[$terminus_package] },
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
