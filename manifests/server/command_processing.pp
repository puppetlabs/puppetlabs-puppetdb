# PRIVATE CLASS - do not use directly
class puppetdb::server::command_processing (
  $command_threads   = $puppetdb::params::command_threads,
  $concurrent_writes = $puppetdb::params::concurrent_writes,
  $store_usage       = $puppetdb::params::store_usage,
  $temp_usage        = $puppetdb::params::temp_usage,
  $confdir           = $puppetdb::params::confdir,
) inherits puppetdb::params {

  $config_ini = "${confdir}/config.ini"

  # Set the defaults
  $ini_setting_defaults = {
    path    => $config_ini,
    section => 'command-processing',
    require => File[$config_ini],
  }

  if $command_threads {
    ini_setting { 'puppetdb_command_processing_threads':
      ensure  => 'present',
      setting => 'threads',
      value   => $command_threads,
      *       => $ini_setting_defaults,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_threads':
      ensure  => 'absent',
      setting => 'threads',
      *       => $ini_setting_defaults,
    }
  }

  if $concurrent_writes {
    ini_setting { 'puppetdb_command_processing_concurrent_writes':
      ensure  => 'present',
      setting => 'concurrent-writes',
      value   => $concurrent_writes,
      *       => $ini_setting_defaults,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_concurrent_writes':
      ensure  => 'absent',
      setting => 'concurrent-writes',
      *       => $ini_setting_defaults,
    }
  }

  if $store_usage {
    ini_setting { 'puppetdb_command_processing_store_usage':
      ensure  => 'present',
      setting => 'store-usage',
      value   => $store_usage,
      *       => $ini_setting_defaults,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_store_usage':
      ensure  => 'absent',
      setting => 'store-usage',
      *       => $ini_setting_defaults,
    }
  }

  if $temp_usage {
    ini_setting { 'puppetdb_command_processing_temp_usage':
      ensure  => 'present',
      setting => 'temp-usage',
      value   => $temp_usage,
      *       => $ini_setting_defaults,
    }
  } else {
    ini_setting { 'puppetdb_command_processing_temp_usage':
      ensure  => 'absent',
      setting => 'temp-usage',
      *       => $ini_setting_defaults,
    }
  }
}
