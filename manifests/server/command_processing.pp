# PRIVATE CLASS - do not use directly
class puppetdb::server::command_processing (
  $command_threads = $puppetdb::params::command_threads,
  $store_usage     = $puppetdb::params::store_usage,
  $temp_usage      = $puppetdb::params::temp_usage,
  $confdir         = $puppetdb::params::confdir,
) inherits puppetdb::params {

  $config_ini = "${confdir}/config.ini"

  # Set the defaults
  Ini_setting {
    path    => $config_ini,
    ensure  => 'present',
    section => 'command-processing',
    require => File[$config_ini],
  }

  if $command_threads {
    ini_setting { 'puppetdb_command_processing_threads':
      setting => 'threads',
      value   => $command_threads,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_threads':
      ensure  => 'absent',
      setting => 'threads',
    }
  }

  if $store_usage {
    ini_setting { 'puppetdb_command_processing_store_usage':
      setting => 'store-usage',
      value   => $store_usage,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_store_usage':
      ensure  => 'absent',
      setting => 'store-usage',
    }
  }

  if $temp_usage {
    ini_setting { 'puppetdb_command_processing_temp_usage':
      setting => 'temp-usage',
      value   => $temp_usage,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_temp_usage':
      ensure  => 'absent',
      setting => 'temp-usage',
    }
  }
}
