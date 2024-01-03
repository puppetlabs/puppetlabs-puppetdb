# PRIVATE CLASS - do not use directly
class puppetdb::server::global (
  $vardir         = $puppetdb::params::vardir,
  $confdir        = $puppetdb::params::confdir,
  $puppetdb_group = $puppetdb::params::puppetdb_group,
) inherits puppetdb::params {

  $config_ini = "${confdir}/config.ini"

  file { $config_ini:
    ensure => file,
    owner  => 'root',
    group  => $puppetdb_group,
    mode   => '0640',
  }

  # Set the defaults
  $ini_setting_defaults = {
    path    => $config_ini,
    section => 'global',
    require => File[$config_ini],
  }

  if $vardir {
    ini_setting { 'puppetdb_global_vardir':
      ensure  => present,
      setting => 'vardir',
      value   => $vardir,
      *       => $ini_setting_defaults,
    }
  }
}
