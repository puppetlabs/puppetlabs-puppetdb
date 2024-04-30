# @summary manage the creation of a read-only postgres users
#
# In particular, it manages the necessary grants to enable such a user
# to have read-only access to any existing objects as well as changes
# the default access privileges so read-only access is maintained when
# new objects are created by the $database_owner
#
# @param read_database_username
#   The name of the postgres read only user.
# @param database_name
#   The name of the database to grant access to.
# @param database_owner
#   The user which owns the database (i.e. the migration user for the database).
# @param password_hash
#   The value of $_database_password in app_database.
# @param password_encryption
#   The hash method for postgresql password, since PostgreSQL 14 default is `scram-sha-256`.
#
# @api private
define puppetdb::database::read_only_user (
  String $read_database_username,
  String $database_name,
  String $database_owner,
  Variant[String, Boolean, Sensitive[String]] $password_hash = false,
  Optional[Stdlib::Port] $database_port = undef,
  Optional[Postgresql::Pg_password_encryption] $password_encryption = undef,
) {
  postgresql::server::role { $read_database_username:
    password_hash => $password_hash,
    port          => $database_port,
    hash          => $password_encryption,
  }

  -> postgresql::server::database_grant { "${database_name} grant connection permission to ${read_database_username}":
    privilege => 'CONNECT',
    db        => $database_name,
    role      => $read_database_username,
    port      => $database_port,
  }

  -> puppetdb::database::default_read_grant {
    "${database_name} grant read permission on new objects from ${database_owner} to ${read_database_username}":
      database_username           => $database_owner,
      database_read_only_username => $read_database_username,
      database_name               => $database_name,
      database_port               => $database_port,
      schema                      => 'public',
  }

  -> puppetdb::database::read_grant {
    "${database_name} grant read-only permission on existing objects to ${read_database_username}":
      database_read_only_username => $read_database_username,
      database_name               => $database_name,
      database_port               => $database_port,
      schema                      => 'public',
  }
}
