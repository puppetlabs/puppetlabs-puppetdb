# @summary validates the database connection
#
# @api private
class puppetdb::server::validate_db (
  $database_host       = $puppetdb::params::database_host,
  $database_port       = $puppetdb::params::database_port,
  $database_username   = $puppetdb::params::database_username,
  $database_password   = $puppetdb::params::database_password,
  $database_name       = $puppetdb::params::database_name,
  $jdbc_ssl_properties = $puppetdb::params::jdbc_ssl_properties,
) inherits puppetdb::params {
  if ($database_password != undef and $jdbc_ssl_properties == false) {
    postgresql_conn_validator { 'validate puppetdb postgres connection':
      host        => $database_host,
      port        => $database_port,
      db_username => $database_username,
      db_password => $database_password,
      db_name     => $database_name,
    }
  }
}
