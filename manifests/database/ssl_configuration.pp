# Class for configuring SSL connection for the PuppetDB postgresql database. See README.md for more
# information.
class puppetdb::database::ssl_configuration(
  $database_name               = $puppetdb::params::database_name,
  $database_username           = $puppetdb::params::database_username,
  $puppetdb_server             = $puppetdb::params::puppetdb_server,
  $postgresql_ssl_key_path     = $puppetdb::params::postgresql_ssl_key_path,
  $postgresql_ssl_cert_path    = $puppetdb::params::postgresql_ssl_cert_path,
  $postgresql_ssl_ca_cert_path = $puppetdb::params::postgresql_ssl_ca_cert_path
) inherits puppetdb::params {

  file {'postgres private key':
    ensure  => present,
    path    => "${postgresql::server::datadir}/server.key",
    source  => $postgresql_ssl_key_path,
    owner   => 'postgres',
    mode    => '0600',
    require => Package['postgresql-server'],
  }

  file {'postgres public key':
    ensure  => present,
    path    => "${postgresql::server::datadir}/server.crt",
    source  => $postgresql_ssl_cert_path,
    owner   => 'postgres',
    mode    => '0600',
    require => Package['postgresql-server'],
  }

  postgresql::server::config_entry {'ssl':
    ensure  => present,
    value   => 'on',
    require => [File['postgres private key'], File['postgres public key']]
  }

  postgresql::server::config_entry {'ssl_cert_file':
    ensure  => present,
    value   => "${postgresql::server::datadir}/server.crt",
    require => [File['postgres private key'], File['postgres public key']]
  }

  postgresql::server::config_entry {'ssl_key_file':
    ensure  => present,
    value   => "${postgresql::server::datadir}/server.key",
    require => [File['postgres private key'], File['postgres public key']]
  }

  postgresql::server::config_entry {'ssl_ca_file':
    ensure  => present,
    value   => $postgresql_ssl_ca_cert_path,
    require => [File['postgres private key'], File['postgres public key']]
  }

  $identity_map_key = "${database_name}-${database_username}-map"

  postgresql::server::pg_hba_rule { "Allow certificate mapped connections to ${database_name} as ${database_username} (ipv4)":
    type        => 'hostssl',
    database    => $database_name,
    user        => $database_username,
    address     => '0.0.0.0/0',
    auth_method => 'cert',
    order       => 0,
    auth_option => "map=${identity_map_key} clientcert=1"
  }

  postgresql::server::pg_hba_rule { "Allow certificate mapped connections to ${database_name} as ${database_username} (ipv6)":
    type        => 'hostssl',
    database    => $database_name,
    user        => $database_username,
    address     => '::0/0',
    auth_method => 'cert',
    order       => 0,
    auth_option => "map=${identity_map_key} clientcert=1"
  }

  postgresql::server::pg_ident_rule {"Map the SSL certificate of the server as a ${database_username} user":
    map_name          => $identity_map_key,
    system_username   => $puppetdb_server,
    database_username => $database_username,
  }
}
