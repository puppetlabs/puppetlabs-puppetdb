# PRIVATE CLASS - do not use directly
class puppetdb::server::jetty_ini(
  $listen_address     = $puppetdb::params::listen_address,
  $listen_port        = $puppetdb::params::listen_port,
  $ssl_listen_address = $puppetdb::params::ssl_listen_address,
  $ssl_listen_port    = $puppetdb::params::ssl_listen_port,
  $disable_ssl        = $puppetdb::params::disable_ssl,
  $confdir            = $puppetdb::params::confdir,
  $max_threads        = $puppetdb::params::max_threads,
) inherits puppetdb::params {

  #Set the defaults
  Ini_setting {
    path    => "${confdir}/jetty.ini",
    ensure  => present,
    section => 'jetty',
  }

  # TODO: figure out some way to make sure that the ini_file module is installed,
  #  because otherwise these will silently fail to do anything.

  ini_setting {'puppetdb_host':
    setting => 'host',
    value   => $listen_address,
  }

  ini_setting {'puppetdb_port':
    setting => 'port',
    value   => $listen_port,
  }

  $ssl_setting_ensure = $disable_ssl ? {
    true    => 'absent',
    default => 'present',
  }

  ini_setting {'puppetdb_sslhost':
    ensure  => $ssl_setting_ensure,
    setting => 'ssl-host',
    value   => $ssl_listen_address,
  }

  ini_setting {'puppetdb_sslport':
    ensure  => $ssl_setting_ensure,
    setting => 'ssl-port',
    value   => $ssl_listen_port,
  }

  if ($max_threads) {
    ini_setting {'puppetdb_max_threads':
      setting => 'max-threads',
      value   => $max_threads,
    }
  } else {
    ini_setting {'puppetdb_max_threads':
      ensure  => absent,
      setting => 'max-threads',
    }
  }
}
