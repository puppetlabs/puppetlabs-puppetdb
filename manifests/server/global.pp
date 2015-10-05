# PRIVATE CLASS - do not use directly
class puppetdb::server::global (
  $vardir  = $puppetdb::params::vardir,
  $confdir = $puppetdb::params::confdir,
) inherits puppetdb::params {

  # Set the defaults
  Ini_setting {
    path    => "${confdir}/config.ini",
    ensure  => 'present',
    section => 'global',
    require => File["${confdir}/config.ini"],
  }

  if $vardir {
    ini_setting { 'puppetdb_global_vardir':
      setting => 'vardir',
      value   => $vardir,
    }
  }
}
