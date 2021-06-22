# Class for configuring SSL connection for the PuppetDB postgresql database. See README.md for more
# information.
class puppetdb::database::ssl_configuration (
  $database_name               = $puppetdb::params::database_name,
  $database_username           = $puppetdb::params::database_username,
  $read_database_username      = $puppetdb::params::read_database_username,
  $read_database_host          = $puppetdb::params::read_database_host,
  $puppetdb_server             = $puppetdb::params::puppetdb_server,
  $postgresql_ssl_key_path     = $puppetdb::params::postgresql_ssl_key_path,
  $postgresql_ssl_cert_path    = $puppetdb::params::postgresql_ssl_cert_path,
  $postgresql_ssl_ca_cert_path = $puppetdb::params::postgresql_ssl_ca_cert_path,
  $create_read_user_rule       = false,
) inherits puppetdb::params {
  File {
    ensure  => present,
    owner   => 'postgres',
    mode    => '0600',
    require => Package['postgresql-server'],
  }

  file { 'postgres private key':
    path   => "${postgresql::server::datadir}/server.key",
    source => $postgresql_ssl_key_path,
  }

  file { 'postgres public key':
    path   => "${postgresql::server::datadir}/server.crt",
    source => $postgresql_ssl_cert_path,
  }

  postgresql::server::config_entry { 'ssl':
    ensure  => present,
    value   => 'on',
    require => [File['postgres private key'], File['postgres public key']]
  }

  postgresql::server::config_entry { 'ssl_cert_file':
    ensure  => present,
    value   => "${postgresql::server::datadir}/server.crt",
    require => [File['postgres private key'], File['postgres public key']]
  }

  postgresql::server::config_entry { 'ssl_key_file':
    ensure  => present,
    value   => "${postgresql::server::datadir}/server.key",
    require => [File['postgres private key'], File['postgres public key']]
  }

  postgresql::server::config_entry { 'ssl_ca_file':
    ensure  => present,
    value   => $postgresql_ssl_ca_cert_path,
    require => [File['postgres private key'], File['postgres public key']]
  }

  puppetdb::database::postgresql_ssl_rules { "Configure postgresql ssl rules for ${database_username}":
    database_name     => $database_name,
    database_username => $database_username,
    puppetdb_server   => $puppetdb_server,
  }

  if $create_read_user_rule {
    puppetdb::database::postgresql_ssl_rules { "Configure postgresql ssl rules for ${read_database_username}":
      database_name     => $database_name,
      database_username => $read_database_username,
      puppetdb_server   => $puppetdb_server,
    }
  }
}
