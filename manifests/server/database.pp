# PRIVATE CLASS - do not use directly
class puppetdb::server::database (
  $database               = $puppetdb::params::database,
  $database_host          = $puppetdb::params::database_host,
  $database_port          = $puppetdb::params::database_port,
  $database_username      = $puppetdb::params::database_username,
  $database_password      = $puppetdb::params::database_password,
  $database_name          = $puppetdb::params::database_name,
  $database_ssl           = $puppetdb::params::database_ssl,
  $jdbc_ssl_properties    = $puppetdb::params::jdbc_ssl_properties,
  $database_validate      = $puppetdb::params::database_validate,
  $database_embedded_path = $puppetdb::params::database_embedded_path,
  $node_ttl               = $puppetdb::params::node_ttl,
  $node_purge_ttl         = $puppetdb::params::node_purge_ttl,
  $report_ttl             = $puppetdb::params::report_ttl,
  $gc_interval            = $puppetdb::params::gc_interval,
  $log_slow_statements    = $puppetdb::params::log_slow_statements,
  $conn_max_age           = $puppetdb::params::conn_max_age,
  $conn_keep_alive        = $puppetdb::params::conn_keep_alive,
  $conn_lifetime          = $puppetdb::params::conn_lifetime,
  $confdir                = $puppetdb::params::confdir,
) inherits puppetdb::params {

  if str2bool($database_validate) {
    # Validate the database connection.  If we can't connect, we want to fail
    # and skip the rest of the configuration, so that we don't leave puppetdb
    # in a broken state.
    #
    # NOTE:
    # Because of a limitation in the postgres module this will break with
    # a duplicate declaration if read and write database host+name are the
    # same.
    class { 'puppetdb::server::validate_db':
      database          => $database,
      database_host     => $database_host,
      database_port     => $database_port,
      database_username => $database_username,
      database_password => $database_password,
      database_name     => $database_name,
    }
  }

  $ini_setting_require = str2bool($database_validate) ? {
    false => undef,
    default  => Class['puppetdb::server::validate_db'],
  }
  # Set the defaults
  Ini_setting {
    path    => "${confdir}/database.ini",
    ensure  => present,
    section => 'database',
    require => $ini_setting_require
  }

  if $database == 'embedded' {

    $classname   = 'org.hsqldb.jdbcDriver'
    $subprotocol = 'hsqldb'
    $subname     = "file:${database_embedded_path};hsqldb.tx=mvcc;sql.syntax_pgs=true"

  } elsif $database == 'postgres' {
    $classname = 'org.postgresql.Driver'
    $subprotocol = 'postgresql'

    if !empty($jdbc_ssl_properties) {
      $database_suffix = $jdbc_ssl_properties
    }
    elsif $database_ssl {
      $database_suffix = "?ssl=true"
    }
    else {
      $database_suffix = ''
    }

    $subname = "//${database_host}:${database_port}/${database_name}${database_suffix}"

    ##Only setup for postgres
    ini_setting {'puppetdb_psdatabase_username':
      setting => 'username',
      value   => $database_username,
    }

    if $database_password != undef {
      ini_setting {'puppetdb_psdatabase_password':
        setting => 'password',
        value   => $database_password,
      }
    }
  }

  ini_setting { 'puppetdb_classname':
    setting => 'classname',
    value   => $classname,
  }

  ini_setting { 'puppetdb_subprotocol':
    setting => 'subprotocol',
    value   => $subprotocol,
  }

  ini_setting { 'puppetdb_pgs':
    setting => 'syntax_pgs',
    value   => true,
  }

  ini_setting { 'puppetdb_subname':
    setting => 'subname',
    value   => $subname,
  }

  ini_setting { 'puppetdb_gc_interval':
    setting => 'gc-interval',
    value   => $gc_interval,
  }

  ini_setting { 'puppetdb_node_ttl':
    setting => 'node-ttl',
    value   => $node_ttl,
  }

  ini_setting { 'puppetdb_node_purge_ttl':
    setting => 'node-purge-ttl',
    value   => $node_purge_ttl,
  }

  ini_setting { 'puppetdb_report_ttl':
    setting => 'report-ttl',
    value   => $report_ttl,
  }

  ini_setting { 'puppetdb_log_slow_statements':
    setting => 'log-slow-statements',
    value   => $log_slow_statements,
  }

  ini_setting { 'puppetdb_conn_max_age':
    setting => 'conn-max-age',
    value   => $conn_max_age,
  }

  ini_setting { 'puppetdb_conn_keep_alive':
    setting => 'conn-keep-alive',
    value   => $conn_keep_alive,
  }

  ini_setting { 'puppetdb_conn_lifetime':
    setting => 'conn-lifetime',
    value   => $conn_lifetime,
  }
}
