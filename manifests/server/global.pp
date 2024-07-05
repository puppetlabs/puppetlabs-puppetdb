# @summary manage puppetdb global setting
#
# @api private
class puppetdb::server::global (
  Stdlib::Absolutepath $vardir         = $puppetdb::params::vardir,
  Stdlib::Absolutepath $confdir        = $puppetdb::params::confdir,
  String[1]            $puppetdb_group = $puppetdb::params::puppetdb_group,
) inherits puppetdb::params {
  $config_ini = "${confdir}/config.ini"

  file { $config_ini:
    ensure => file,
    owner  => 'root',
    group  => $puppetdb_group,
    mode   => '0640',
  }

  # Set the defaults
  Ini_setting {
    path    => $config_ini,
    ensure  => 'present',
    section => 'global',
    require => File[$config_ini],
  }

  if $vardir {
    ini_setting { 'puppetdb_global_vardir':
      setting => 'vardir',
      value   => $vardir,
    }
  }
}
