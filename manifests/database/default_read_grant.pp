# Private class. Grant read permissions to $database_read_only_username by default, for new tables created by
# $database_username.
define puppetdb::database::default_read_grant(
  String $database_name,
  String $schema,
  String $database_username,
  String $database_read_only_username,
) {
  postgresql_psql {"grant default select permission for ${database_read_only_username}":
    db      => $database_name,
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
                WHERE acl.defaclacl::text ~ '.*\\\\\"${database_read_only_username}\\\\\"=r/${database_username}\\\".*'
                AND nspname = '${schema}'",
  }

  postgresql_psql {"grant default usage permission for ${database_read_only_username}":
    db      => $database_name,
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
                WHERE acl.defaclacl::text ~ '.*\\\\\"${database_read_only_username}\\\\\"=U/${database_username}\\\".*'
                AND nspname = '${schema}'",
  }

  postgresql_psql {"grant default execute permission for ${database_read_only_username}":
    db      => $database_name,
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
                WHERE acl.defaclacl::text ~ '.*\\\\\"${database_read_only_username}\\\\\"=X/${database_username}\\\".*'
                AND nspname = '${schema}'",
  }
}
