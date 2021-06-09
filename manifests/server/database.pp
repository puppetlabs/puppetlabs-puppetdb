# PRIVATE CLASS - do not use directly
class puppetdb::server::database (
  $database                  = $puppetdb::params::database,
  $database_host             = $puppetdb::params::database_host,
  $database_port             = $puppetdb::params::database_port,
  $database_username         = $puppetdb::params::database_username,
  $database_password         = $puppetdb::params::database_password,
  $database_name             = $puppetdb::params::database_name,
  $manage_db_password        = $puppetdb::params::manage_db_password,
  $jdbc_ssl_properties       = $puppetdb::params::jdbc_ssl_properties,
  $database_validate         = $puppetdb::params::database_validate,
  $database_embedded_path    = $puppetdb::params::database_embedded_path,
  $node_ttl                  = $puppetdb::params::node_ttl,
  $node_purge_ttl            = $puppetdb::params::node_purge_ttl,
  $report_ttl                = $puppetdb::params::report_ttl,
  $facts_blacklist           = $puppetdb::params::facts_blacklist,
  $gc_interval               = $puppetdb::params::gc_interval,
  $node_purge_gc_batch_limit = $puppetdb::params::node_purge_gc_batch_limit,
  $log_slow_statements       = $puppetdb::params::log_slow_statements,
  $conn_max_age              = $puppetdb::params::conn_max_age,
  $conn_keep_alive           = $puppetdb::params::conn_keep_alive,
  $conn_lifetime             = $puppetdb::params::conn_lifetime,
  $confdir                   = $puppetdb::params::confdir,
  $puppetdb_user             = $puppetdb::params::puppetdb_user,
  $puppetdb_group            = $puppetdb::params::puppetdb_group,
  $database_max_pool_size    = $puppetdb::params::database_max_pool_size,
  $migrate                   = $puppetdb::params::migrate,
  $postgresql_ssl_on         = $puppetdb::params::postgresql_ssl_on,
  $ssl_cert_path             = $puppetdb::params::ssl_cert_path,
  $ssl_key_pk8_path          = $puppetdb::params::ssl_key_pk8_path,
  $ssl_ca_cert_path          = $puppetdb::params::ssl_ca_cert_path
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

  $database_ini = "${confdir}/database.ini"

  file { $database_ini:
    ensure => file,
    owner  => $puppetdb_user,
    group  => $puppetdb_group,
    mode   => '0600',
  }

  $file_require = File[$database_ini]
  $ini_setting_require = str2bool($database_validate) ? {
    false   => $file_require,
    default => [$file_require, Class['puppetdb::server::validate_db']],
  }
  # Set the defaults
  Ini_setting {
    path    => $database_ini,
    ensure  => present,
    section => 'database',
    require => $ini_setting_require
  }

  if $database == 'embedded' {

    $classname = 'org.hsqldb.jdbcDriver'
    $subprotocol = 'hsqldb'
    $subname = "file:${database_embedded_path};hsqldb.tx=mvcc;sql.syntax_pgs=true"

  } elsif $database == 'postgres' {
    $classname = 'org.postgresql.Driver'
    $subprotocol = 'postgresql'

    if !empty($jdbc_ssl_properties) {
      $database_suffix = $jdbc_ssl_properties
    }
    else {
      $database_suffix = ''
    }

    $subname_default = "//${database_host}:${database_port}/${database_name}${database_suffix}"

    if $postgresql_ssl_on and !empty($jdbc_ssl_properties)
    {
      fail("Variables 'postgresql_ssl_on' and 'jdbc_ssl_properties' can not be used at the same time!")
    }

    if $postgresql_ssl_on {
      $subname = @("EOT"/L)
        ${subname_default}?\
        ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&\
        sslmode=verify-full&sslrootcert=${ssl_ca_cert_path}&\
        sslkey=${ssl_key_pk8_path}&sslcert=${ssl_cert_path}\
        | EOT
    } else {
      $subname = $subname_default
    }

    ##Only setup for postgres
    ini_setting { 'puppetdb_psdatabase_username':
      setting => 'username',
      value   => $database_username,
    }

    if $database_password != undef and $manage_db_password {
      ini_setting { 'puppetdb_psdatabase_password':
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

  ini_setting { 'puppetdb_node_purge_gc_batch_limit':
    setting => 'node-purge-gc-batch-limit',
    value   => $node_purge_gc_batch_limit,
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

  ini_setting { 'puppetdb_migrate':
    setting => 'migrate',
    value   => $migrate,
  }

  if $puppetdb::params::database_max_pool_size_setting_name != undef {
    if $database_max_pool_size == 'absent' {
      ini_setting { 'puppetdb_database_max_pool_size':
        ensure  => absent,
        setting => $puppetdb::params::database_max_pool_size_setting_name,
      }
    } elsif $database_max_pool_size != undef {
      ini_setting { 'puppetdb_database_max_pool_size':
        setting => $puppetdb::params::database_max_pool_size_setting_name,
        value   => $database_max_pool_size,
      }
    }
  }

  if ($facts_blacklist) and length($facts_blacklist) != 0 {
    $joined_facts_blacklist = join($facts_blacklist, ', ')
    ini_setting { 'puppetdb_facts_blacklist':
      setting => 'facts-blacklist',
      value   => $joined_facts_blacklist,
    }
  } else {
    ini_setting { 'puppetdb_facts_blacklist':
      ensure  => absent,
      setting => 'facts-blacklist',
    }
  }
}
