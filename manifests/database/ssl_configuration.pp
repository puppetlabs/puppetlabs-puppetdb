# @summary configure SSL for the PuppetDB postgresql database
#
# @api private
class puppetdb::database::ssl_configuration (
  String[1]              $database_name               = $puppetdb::params::database_name,
  String[1]              $database_username           = $puppetdb::params::database_username,
  String[1]              $read_database_username      = $puppetdb::params::read_database_username,
  Optional[Stdlib::Host] $read_database_host          = $puppetdb::params::read_database_host,
  String[1]              $puppetdb_server             = $puppetdb::params::puppetdb_server,
  Stdlib::Absolutepath   $postgresql_ssl_key_path     = $puppetdb::params::postgresql_ssl_key_path,
  Stdlib::Absolutepath   $postgresql_ssl_cert_path    = $puppetdb::params::postgresql_ssl_cert_path,
  Stdlib::Absolutepath   $postgresql_ssl_ca_cert_path = $puppetdb::params::postgresql_ssl_ca_cert_path,
  String[2,3]            $postgres_version            = $puppetdb::params::postgres_version,
  Boolean                $create_read_user_rule       = false,
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
    require => [File['postgres private key'], File['postgres public key']],
  }

  postgresql::server::config_entry { 'ssl_cert_file':
    ensure  => present,
    value   => "${postgresql::server::datadir}/server.crt",
    require => [File['postgres private key'], File['postgres public key']],
  }

  postgresql::server::config_entry { 'ssl_key_file':
    ensure  => present,
    value   => "${postgresql::server::datadir}/server.key",
    require => [File['postgres private key'], File['postgres public key']],
  }

  postgresql::server::config_entry { 'ssl_ca_file':
    ensure  => present,
    value   => $postgresql_ssl_ca_cert_path,
    require => [File['postgres private key'], File['postgres public key']],
  }

  puppetdb::database::postgresql_ssl_rules { "Configure postgresql ssl rules for ${database_username}":
    database_name     => $database_name,
    database_username => $database_username,
    postgres_version  => $postgres_version,
    puppetdb_server   => $puppetdb_server,
  }

  if $create_read_user_rule {
    puppetdb::database::postgresql_ssl_rules { "Configure postgresql ssl rules for ${read_database_username}":
      database_name     => $database_name,
      database_username => $read_database_username,
      postgres_version  => $postgres_version,
      puppetdb_server   => $puppetdb_server,
    }
  }
}
