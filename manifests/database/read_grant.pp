# Private class. Grant read-only permissions to $database_read_only_username for all objects in $schema of
# $database_name
define puppetdb::database::read_grant (
  String $database_name,
  String $schema,
  String $database_read_only_username,
) {
  postgresql_psql { "grant select permission for ${database_read_only_username}":
    db      => $database_name,
    command => "GRANT SELECT
                ON ALL TABLES IN SCHEMA \"${schema}\"
                TO \"${database_read_only_username}\"",
    unless  => "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM pg_tables
                  WHERE schemaname='public'
                    AND has_table_privilege('${database_read_only_username}', schemaname || '.' || tablename, 'SELECT')=false
                ) x
                WHERE x.count=0",
  }

  postgresql_psql { "grant usage permission for ${database_read_only_username}":
    db      => $database_name,
    command => "GRANT USAGE
                ON ALL SEQUENCES IN SCHEMA \"${schema}\"
                TO \"${database_read_only_username}\"",
    unless  => "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM information_schema.sequences
                  WHERE sequence_schema='public'
                    AND has_sequence_privilege('${database_read_only_username}', sequence_schema || '.' || sequence_name, 'USAGE')=false
                ) x
                WHERE x.count=0",
  }

  postgresql_psql { "grant execution permission for ${database_read_only_username}":
    db      => $database_name,
    command => "GRANT EXECUTE
                ON ALL FUNCTIONS IN SCHEMA \"${schema}\"
                TO \"${database_read_only_username}\"",
    unless  => "SELECT * FROM (
                  SELECT COUNT(*)
                  FROM pg_catalog.pg_proc p
                  LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
                  WHERE n.nspname='public'
                    AND has_function_privilege('${database_read_only_username}', p.oid, 'EXECUTE')=false
                ) x
                WHERE x.count=0",
  }
}
