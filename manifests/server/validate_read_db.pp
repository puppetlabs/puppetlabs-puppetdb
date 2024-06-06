# @summary validates the read only database connection
#
# @api private
class puppetdb::server::validate_read_db (
  Stdlib::Host                                               $database_host       = $puppetdb::params::database_host,
  Variant[Stdlib::Port::Unprivileged, Pattern[/\A[0-9]+\Z/]] $database_port       = $puppetdb::params::database_port,
  String[1]                                                  $database_username   = $puppetdb::params::database_username,
  Variant[String[1], Sensitive[String[1]]]                   $database_password   = $puppetdb::params::database_password,
  String[1]                                                  $database_name       = $puppetdb::params::database_name,
  Variant[String, Boolean]                                   $jdbc_ssl_properties = $puppetdb::params::jdbc_ssl_properties,
) inherits puppetdb::params {
  if ($database_password != undef and $jdbc_ssl_properties == false) {
    postgresql_conn_validator { 'validate puppetdb postgres (read) connection':
      host        => $database_host,
      port        => $database_port,
      db_username => $database_username,
      db_password => $database_password,
      db_name     => $database_name,
    }
  }
}
