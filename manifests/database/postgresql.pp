# Class for creating the PuppetDB postgresql database. See README.md for more
# information.
class puppetdb::database::postgresql (
  $listen_addresses            = $puppetdb::params::database_host,
  $puppetdb_server             = $puppetdb::params::puppetdb_server,
  $database_name               = $puppetdb::params::database_name,
  $database_username           = $puppetdb::params::database_username,
  $database_password           = $puppetdb::params::database_password,
  $database_port               = $puppetdb::params::database_port,
  $manage_database             = $puppetdb::params::manage_database,
  $manage_server               = $puppetdb::params::manage_dbserver,
  $manage_package_repo         = $puppetdb::params::manage_pg_repo,
  $postgres_version            = $puppetdb::params::postgres_version,
  $postgresql_ssl_on           = $puppetdb::params::postgresql_ssl_on,
  $postgresql_ssl_key_path     = $puppetdb::params::postgresql_ssl_key_path,
  $postgresql_ssl_cert_path    = $puppetdb::params::postgresql_ssl_cert_path,
  $postgresql_ssl_ca_cert_path = $puppetdb::params::postgresql_ssl_ca_cert_path,
  $read_database_username      = $puppetdb::params::read_database_username,
  $read_database_password      = $puppetdb::params::read_database_password,
  $read_database_host          = $puppetdb::params::read_database_host
) inherits puppetdb::params {

  if $manage_server {
    class { '::postgresql::globals':
      manage_package_repo => $manage_package_repo,
      version             => $postgres_version,
    }
    # get the pg server up and running
    class { '::postgresql::server':
      ip_mask_allow_all_users => '0.0.0.0/0',
      listen_addresses        => $listen_addresses,
      port                    => scanf($database_port, '%i')[0],
    }

    # We need to create the ssl connection for the read user, when
    # manage_database is set to true, or when read_database_host is defined.
    # Otherwise we don't create it.
    if $manage_database or $read_database_host != undef{
      $create_read_user_rule = true
    } else {
      $create_read_user_rule = false
    }

    # configure PostgreSQL communication with Puppet Agent SSL certificates if
    # postgresql_ssl_on is set to true
    if $postgresql_ssl_on {
      class { 'puppetdb::database::ssl_configuration':
        database_name               => $database_name,
        database_username           => $database_username,
        read_database_username      => $read_database_username,
        puppetdb_server             => $puppetdb_server,
        postgresql_ssl_key_path     => $postgresql_ssl_key_path,
        postgresql_ssl_cert_path    => $postgresql_ssl_cert_path,
        postgresql_ssl_ca_cert_path => $postgresql_ssl_ca_cert_path,
        create_read_user_rule       => $create_read_user_rule
      }
    }

    # Only install pg_trgm extension, if database it is actually managed by the module
    if $manage_database {

      # get the pg contrib to use pg_trgm extension
      class { '::postgresql::server::contrib': }

      postgresql::server::extension { 'pg_trgm':
        database => $database_name,
        require  => Postgresql::Server::Db[$database_name],
      }
    }
  }

  if $manage_database {
    # create the puppetdb database
    postgresql::server::db { $database_name:
      user     => $database_username,
      password => $database_password,
      grant    => 'all',
    }

    -> postgresql_psql { 'revoke all access on public schema':
      db      => $database_name,
      command => 'REVOKE CREATE ON SCHEMA public FROM public',
      unless  => "SELECT * FROM
                  (SELECT has_schema_privilege('public', 'public', 'create') can_create) privs
                WHERE privs.can_create=false",
    }

    -> postgresql_psql { "grant all permissions to ${database_username}":
      db      => $database_name,
      command => "GRANT CREATE ON SCHEMA public TO \"${database_username}\"",
      unless  => "SELECT * FROM
                  (SELECT has_schema_privilege('${database_username}', 'public', 'create') can_create) privs
                WHERE privs.can_create=true",
    }

    -> puppetdb::database::read_only_user { $read_database_username:
      read_database_username => $read_database_username,
      database_name          => $database_name,
      password_hash          => postgresql::postgresql_password($read_database_username, $read_database_password),
      database_owner         => $database_username
    }
  }
}
