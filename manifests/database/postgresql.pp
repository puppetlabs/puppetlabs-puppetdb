# @summary create the PuppetDB postgresql database
#
# @param listen_addresses
#   The `listen_address` is a comma-separated list of hostnames or IP addresses on
#   which the postgres server should listen for incoming connections. This defaults
#   to `localhost`. This parameter maps directly to PostgreSQL's `listen_addresses`
#   config option. Use a `*` to allow connections on any accessible address.
#
# @param puppetdb_server
#   Hostname or IP address to configure for SSL rules.
#
# @param database_name
#   Sets the name of the database. Defaults to `puppetdb`.
#
# @param database_username
#   Creates a user for access the database. Defaults to `puppetdb`.
#
# @param database_password
#   Sets the password for the database user above. Defaults to `puppetdb`.
#
# @param database_port
#   The port that the database server listens on. Defaults to `5432`.
#
# @param manage_database
#   If true, the PostgreSQL database will be managed by this module. Defaults to `true`.
#
# @param manage_server
#   Conditionally manages the PostgreSQL server via `postgresql::server`. Defaults
#   to `true`. If set to `false`, this class will create the database and user via
#   `postgresql::server::db` but not attempt to install or manage the server itself.
#
# @param manage_package_repo
#   If `true`, the official postgresql.org repo will be added and postgres won't
#   be installed from the regular repository. Defaults to `true`.
#
# @param postgres_version
#   If the postgresql.org repo is installed, you can install several versions of
#   postgres. Defaults to `11` with PuppetDB version 7.0.0 or newer, and `9.6` in older versions.
#
# @param postgresql_ssl_on
#   If `true`, it configures SSL connections between PuppetDB and the PostgreSQL database.
#   Defaults to `false`.
#
# @param postgresql_ssl_cert_path
#   Path to the Postgresql SSL certificate.
#
# @param postgresql_ssl_key_path
#   Path to the Postgresql SSL key.
#
# @param postgresql_ssl_ca_cert_path
#   Path to the Postgresql SSL CA.
#
# @param read_database_username
#   The name of the read database user to connect as. Defaults to `puppetdb-read`. This
#   option is supported in PuppetDB >= 1.6.
#
# @param read_database_password
#   The password for the read database user. Defaults to `puppetdb-read`. This option is
#   supported in PuppetDB >= 1.6.
#
# @param read_database_host
#   *This parameter must be set to use another PuppetDB instance for queries.*
#
#   The hostname or IP address of the read database server. If set to `undef`, and
#   `manage_database` is set to `true`, it will use the value of the `database_host`
#   parameter. This option is supported in PuppetDB >= 1.6.
#
# @param password_sensitive
#   Whether password should be of Datatype Sensitive[String]
# @param password_encryption
#   PostgreSQL password authentication method, either `md5` or `scram-sha-256`
#
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
  $read_database_host          = $puppetdb::params::read_database_host,
  Boolean $password_sensitive  = false,
  Postgresql::Pg_password_encryption $password_encryption = $puppetdb::params::password_encryption,
) inherits puppetdb::params {
  $port = scanf($database_port, '%i')[0]

  if $manage_server {
    class { 'postgresql::globals':
      manage_package_repo => $manage_package_repo,
      version             => $postgres_version,
    }
    # get the pg server up and running
    class { 'postgresql::server':
      ip_mask_allow_all_users => '0.0.0.0/0',
      listen_addresses        => $listen_addresses,
      port                    => $port,
      password_encryption     => $password_encryption,
    }

    # We need to create the ssl connection for the read user, when
    # manage_database is set to true, or when read_database_host is defined.
    # Otherwise we don't create it.
    if $manage_database or $read_database_host != undef {
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
        postgres_version            => $postgres_version,
        create_read_user_rule       => $create_read_user_rule,
      }
    }

    # Only install pg_trgm extension, if database it is actually managed by the module
    if $manage_database {
      # get the pg contrib to use pg_trgm extension
      class { 'postgresql::server::contrib': }

      postgresql::server::extension { 'pg_trgm':
        database => $database_name,
        require  => Postgresql::Server::Db[$database_name],
        port     => $port,
      }
    }
  }

  if $manage_database {
    # create the puppetdb database
    postgresql::server::db { $database_name:
      user     => $database_username,
      password => $database_password,
      encoding => 'UTF8',
      locale   => 'en_US.UTF-8',
      grant    => 'all',
      port     => $port,
    }

    -> postgresql_psql { 'revoke all access on public schema':
      db      => $database_name,
      port    => $port,
      command => 'REVOKE CREATE ON SCHEMA public FROM public',
      unless  => "SELECT * FROM
                  (SELECT has_schema_privilege('public', 'public', 'create') can_create) privs
                WHERE privs.can_create=false",
    }

    -> postgresql_psql { "grant all permissions to ${database_username}":
      db      => $database_name,
      port    => $port,
      command => "GRANT CREATE ON SCHEMA public TO \"${database_username}\"",
      unless  => "SELECT * FROM
                  (SELECT has_schema_privilege('${database_username}', 'public', 'create') can_create) privs
                WHERE privs.can_create=true",
    }

    -> puppetdb::database::read_only_user { $read_database_username:
      read_database_username => $read_database_username,
      database_name          => $database_name,
      password_hash          => postgresql::postgresql_password(
      $read_database_username, $read_database_password, $password_sensitive, $password_encryption),
      database_owner         => $database_username,
      database_port          => $port,
      password_encryption    => $password_encryption,
    }

    -> postgresql_psql { "grant ${read_database_username} role to ${database_username}":
      db      => $database_name,
      port    => $port,
      command => "GRANT \"${read_database_username}\" TO \"${database_username}\"",
      unless  => "SELECT oid, rolname FROM pg_roles WHERE
                   pg_has_role( '${database_username}', oid, 'member') and rolname = '${read_database_username}'";
    }
  }
}
