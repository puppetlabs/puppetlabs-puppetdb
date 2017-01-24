# PRIVATE CLASS - do not use directly
class puppetdb::server::jetty (
  $listen_address     = $puppetdb::params::listen_address,
  $listen_port        = $puppetdb::params::listen_port,
  $disable_cleartext  = $puppetdb::params::disable_cleartext,
  $ssl_listen_address = $puppetdb::params::ssl_listen_address,
  $ssl_listen_port    = $puppetdb::params::ssl_listen_port,
  $disable_ssl        = $puppetdb::params::disable_ssl,
  $ssl_set_cert_paths = $puppetdb::params::ssl_set_cert_paths,
  $ssl_cert_path      = $puppetdb::params::ssl_cert_path,
  $ssl_key_path       = $puppetdb::params::ssl_key_path,
  $ssl_ca_cert_path   = $puppetdb::params::ssl_ca_cert_path,
  $ssl_protocols      = $puppetdb::params::ssl_protocols,
  $cipher_suites      = $puppetdb::params::cipher_suites,
  $confdir            = $puppetdb::params::confdir,
  $max_threads        = $puppetdb::params::max_threads,
  $puppetdb_user      = $puppetdb::params::puppetdb_user,
  $puppetdb_group     = $puppetdb::params::puppetdb_group,
) inherits puppetdb::params {

  $jetty_ini = "${confdir}/jetty.ini"

  file { $jetty_ini:
    ensure => file,
    owner  => $puppetdb_user,
    group  => $puppetdb_group,
    mode   => '0600',
  }

  # Set the defaults
  Ini_setting {
    path    => $jetty_ini,
    ensure  => present,
    section => 'jetty',
    require => File[$jetty_ini],
  }

  $cleartext_setting_ensure = $disable_cleartext ? {
    true    => 'absent',
    default => 'present',
  }

  ini_setting { 'puppetdb_host':
    ensure  => $cleartext_setting_ensure,
    setting => 'host',
    value   => $listen_address,
  }

  ini_setting { 'puppetdb_port':
    ensure  => $cleartext_setting_ensure,
    setting => 'port',
    value   => $listen_port,
  }

  $ssl_setting_ensure = $disable_ssl ? {
    true    => 'absent',
    default => 'present',
  }

  ini_setting { 'puppetdb_sslhost':
    ensure  => $ssl_setting_ensure,
    setting => 'ssl-host',
    value   => $ssl_listen_address,
  }

  ini_setting { 'puppetdb_sslport':
    ensure  => $ssl_setting_ensure,
    setting => 'ssl-port',
    value   => $ssl_listen_port,
  }

  if $ssl_protocols != undef {

    validate_string($ssl_protocols)

    ini_setting { 'puppetdb_sslprotocols':
      ensure  => $ssl_setting_ensure,
      setting => 'ssl-protocols',
      value   => $ssl_protocols,
    }
  }

  if $cipher_suites != undef {

    validate_string($cipher_suites)

    ini_setting { 'puppetdb_cipher-suites':
      ensure  => $ssl_setting_ensure,
      setting => 'cipher-suites',
      value   => $cipher_suites,
    }
  }

  if str2bool($ssl_set_cert_paths) == true {
    # assume paths have been validated in calling class
    ini_setting { 'puppetdb_ssl_key':
      ensure  => present,
      setting => 'ssl-key',
      value   => $ssl_key_path,
    }
    ini_setting { 'puppetdb_ssl_cert':
      ensure  => present,
      setting => 'ssl-cert',
      value   => $ssl_cert_path,
    }
    ini_setting { 'puppetdb_ssl_ca_cert':
      ensure  => present,
      setting => 'ssl-ca-cert',
      value   => $ssl_ca_cert_path,
    }
  }

  if ($max_threads) {
    ini_setting { 'puppetdb_max_threads':
      setting => 'max-threads',
      value   => $max_threads,
    }
  } else {
    ini_setting { 'puppetdb_max_threads':
      ensure  => absent,
      setting => 'max-threads',
    }
  }
}
