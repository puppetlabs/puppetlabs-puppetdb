# @summary grant read permissions to $database_read_only_username by default, for new tables created by $database_username
#
# @api private
define puppetdb::database::default_read_grant (
  String $database_name,
  String $schema,
  String $database_username,
  String $database_read_only_username,
  Optional[Stdlib::Port] $database_port = undef,
) {
  postgresql_psql { "grant default select permission for ${database_read_only_username}":
    db      => $database_name,
    port    => $database_port,
    command => "ALTER DEFAULT PRIVILEGES
                  FOR USER \"${database_username}\"
                  IN SCHEMA \"${schema}\"
                GRANT SELECT ON TABLES
                  TO \"${database_read_only_username}\"",
    unless  => "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE '@' || array_to_string(acl.defaclacl, '@') || '@' ~ '@(\"?)${database_read_only_username}\\1=r/(\"?)${database_username}\\2@'
                AND nspname = '${schema}'",
  }

  postgresql_psql { "grant default usage permission for ${database_read_only_username}":
    db      => $database_name,
    port    => $database_port,
    command => "ALTER DEFAULT PRIVILEGES
                  FOR USER \"${database_username}\"
                  IN SCHEMA \"${schema}\"
                GRANT USAGE ON SEQUENCES
                  TO \"${database_read_only_username}\"",
    unless  => "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE '@' || array_to_string(acl.defaclacl, '@') || '@' ~ '@(\"?)${database_read_only_username}\\1=U/(\"?)${database_username}\\2@'
                AND nspname = '${schema}'",
  }

  postgresql_psql { "grant default execute permission for ${database_read_only_username}":
    db      => $database_name,
    port    => $database_port,
    command => "ALTER DEFAULT PRIVILEGES
                  FOR USER \"${database_username}\"
                  IN SCHEMA \"${schema}\"
                GRANT EXECUTE ON FUNCTIONS
                  TO \"${database_read_only_username}\"",
    unless  => "SELECT
                  ns.nspname,
                  acl.defaclobjtype,
                  acl.defaclacl
                FROM pg_default_acl acl
                JOIN pg_namespace ns ON acl.defaclnamespace=ns.oid
                WHERE '@' || array_to_string(acl.defaclacl, '@') || '@' ~ '@(\"?)${database_read_only_username}\\1=X/(\"?)${database_username}\\2@'
                AND nspname = '${schema}'",
  }
}
