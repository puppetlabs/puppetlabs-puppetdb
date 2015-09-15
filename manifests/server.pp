# Class to configure a PuppetDB server. See README.md for more details.
class puppetdb::server (
  $listen_address                    = $puppetdb::params::listen_address,
  $listen_port                       = $puppetdb::params::listen_port,
  $open_listen_port                  = $puppetdb::params::open_listen_port,
  $ssl_listen_address                = $puppetdb::params::ssl_listen_address,
  $ssl_listen_port                   = $puppetdb::params::ssl_listen_port,
  $disable_ssl                       = $puppetdb::params::disable_ssl,
  $open_ssl_listen_port              = $puppetdb::params::open_ssl_listen_port,
  $ssl_dir                           = $puppetdb::params::ssl_dir,
  $ssl_set_cert_paths                = $puppetdb::params::ssl_set_cert_paths,
  $ssl_cert_path                     = $puppetdb::params::ssl_cert_path,
  $ssl_key_path                      = $puppetdb::params::ssl_key_path,
  $ssl_ca_cert_path                  = $puppetdb::params::ssl_ca_cert_path,
  $ssl_deploy_certs                  = $puppetdb::params::ssl_deploy_certs,
  $ssl_key                           = $puppetdb::params::ssl_key,
  $ssl_cert                          = $puppetdb::params::ssl_cert,
  $ssl_ca_cert                       = $puppetdb::params::ssl_ca_cert,
  $ssl_protocols                     = $puppetdb::params::ssl_protocols,
  $database                          = $puppetdb::params::database,
  $database_host                     = $puppetdb::params::database_host,
  $database_port                     = $puppetdb::params::database_port,
  $database_username                 = $puppetdb::params::database_username,
  $database_password                 = $puppetdb::params::database_password,
  $database_name                     = $puppetdb::params::database_name,
  $database_ssl                      = $puppetdb::params::database_ssl,
  $jdbc_ssl_properties               = $puppetdb::params::jdbc_ssl_properties,
  $database_validate                 = $puppetdb::params::database_validate,
  $database_embedded_path            = $puppetdb::params::database_embedded_path,
  $node_ttl                          = $puppetdb::params::node_ttl,
  $node_purge_ttl                    = $puppetdb::params::node_purge_ttl,
  $report_ttl                        = $puppetdb::params::report_ttl,
  $gc_interval                       = $puppetdb::params::gc_interval,
  $log_slow_statements               = $puppetdb::params::log_slow_statements,
  $conn_max_age                      = $puppetdb::params::conn_max_age,
  $conn_keep_alive                   = $puppetdb::params::conn_keep_alive,
  $conn_lifetime                     = $puppetdb::params::conn_lifetime,
  $puppetdb_package                  = $puppetdb::params::puppetdb_package,
  $puppetdb_service                  = $puppetdb::params::puppetdb_service,
  $puppetdb_service_status           = $puppetdb::params::puppetdb_service_status,
  $puppetdb_user                     = $puppetdb::params::puppetdb_user,
  $puppetdb_group                    = $puppetdb::params::puppetdb_group,
  $read_database                     = $puppetdb::params::read_database,
  $read_database_host                = $puppetdb::params::read_database_host,
  $read_database_port                = $puppetdb::params::read_database_port,
  $read_database_username            = $puppetdb::params::read_database_username,
  $read_database_password            = $puppetdb::params::read_database_password,
  $read_database_name                = $puppetdb::params::read_database_name,
  $read_database_ssl                 = $puppetdb::params::read_database_ssl,
  $read_database_jdbc_ssl_properties = $puppetdb::params::read_database_jdbc_ssl_properties,
  $read_database_validate            = $puppetdb::params::read_database_validate,
  $read_log_slow_statements          = $puppetdb::params::read_log_slow_statements,
  $read_conn_max_age                 = $puppetdb::params::read_conn_max_age,
  $read_conn_keep_alive              = $puppetdb::params::read_conn_keep_alive,
  $read_conn_lifetime                = $puppetdb::params::read_conn_lifetime,
  $confdir                           = $puppetdb::params::confdir,
  $manage_firewall                   = $puppetdb::params::manage_firewall,
  $java_args                         = $puppetdb::params::java_args,
  $max_threads                       = $puppetdb::params::max_threads,
  $command_threads                   = $puppetdb::params::command_threads,
  $store_usage                       = $puppetdb::params::store_usage,
  $temp_usage                        = $puppetdb::params::temp_usage,
) inherits puppetdb::params {
  # deprecation warnings
  if $database_ssl != undef {
    warning('$database_ssl is deprecated and will be removed in the next major release. Please use $jdbc_ssl_properties = "?ssl=true" instead.')
  }

  if $read_database_ssl != undef {
    warning('$read_database_ssl is deprecated and will be removed in the next major release. Please use $read_database_jdbc_ssl_properties = "?ssl=true" instead.')
  }

  # Apply necessary suffix if zero is specified.
  if $node_ttl == '0' {
    $node_ttl_real = '0s'
  } else {
    $node_ttl_real = downcase($node_ttl)
  }

  # Validate node_ttl
  validate_re ($node_ttl_real, ['^\d+(d|h|m|s|ms)$'], "node_ttl is <${node_ttl}> which does not match the regex validation")

  # Apply necessary suffix if zero is specified.
  if $node_purge_ttl == '0' {
    $node_purge_ttl_real = '0s'
  } else {
    $node_purge_ttl_real = downcase($node_purge_ttl)
  }

  # Validate node_purge_ttl
  validate_re ($node_purge_ttl_real, ['^\d+(d|h|m|s|ms)$'], "node_purge_ttl is <${node_purge_ttl}> which does not match the regex validation")

  # Apply necessary suffix if zero is specified.
  if $report_ttl == '0' {
    $report_ttl_real = '0s'
  } else {
    $report_ttl_real = downcase($report_ttl)
  }

  # Validate report_ttl
  validate_re ($report_ttl_real, ['^\d+(d|h|m|s|ms)$'], "report_ttl is <${report_ttl}> which does not match the regex validation")

  # Validate puppetdb_service_status
  $service_enabled = $puppetdb_service_status ? {
    /(running|true)/  => true,
    /(stopped|false)/ => false,
    default           => fail("puppetdb_service_status valid values are 'true', 'running', 'false', and 'stopped'. You provided '${puppetdb_service_status}'"),
  }

  # Validate database type (Currently only postgres and embedded are supported)
  if !($database in ['postgres', 'embedded']) {
    fail("database must must be 'postgres' or 'embedded'. You provided '${database}'")
  }

  # Validate read-database type (Currently only postgres is supported)
  if !($read_database in ['postgres']) {
    fail("read_database must be 'postgres'. You provided '${read_database}'")
  }

  package { $puppetdb_package:
    ensure => $puppetdb::params::puppetdb_version,
    notify => Service[$puppetdb_service],
  }

  if $manage_firewall {
    class { 'puppetdb::server::firewall':
      http_port      => $listen_port,
      open_http_port => $open_listen_port,
      ssl_port       => $ssl_listen_port,
      open_ssl_port  => $open_ssl_listen_port,
    }
  }

  class { 'puppetdb::server::command_processing':
    command_threads => $command_threads,
    store_usage     => $store_usage,
    temp_usage      => $temp_usage,
    confdir         => $confdir,
    notify          => Service[$puppetdb_service],
  }

  class { 'puppetdb::server::database':
    database               => $database,
    database_host          => $database_host,
    database_port          => $database_port,
    database_username      => $database_username,
    database_password      => $database_password,
    database_name          => $database_name,
    database_ssl           => $database_ssl,
    jdbc_ssl_properties    => $jdbc_ssl_properties,
    database_validate      => $database_validate,
    database_embedded_path => $database_embedded_path,
    node_ttl               => $node_ttl,
    node_purge_ttl         => $node_purge_ttl,
    report_ttl             => $report_ttl,
    gc_interval            => $gc_interval,
    log_slow_statements    => $log_slow_statements,
    conn_max_age           => $conn_max_age,
    conn_keep_alive        => $conn_keep_alive,
    conn_lifetime          => $conn_lifetime,
    confdir                => $confdir,
    notify                 => Service[$puppetdb_service],
  }

  class { 'puppetdb::server::read_database':
    database            => $read_database,
    database_host       => $read_database_host,
    database_port       => $read_database_port,
    database_username   => $read_database_username,
    database_password   => $read_database_password,
    database_name       => $read_database_name,
    database_ssl        => $read_database_ssl,
    jdbc_ssl_properties => $read_database_jdbc_ssl_properties,
    database_validate   => $read_database_validate,
    log_slow_statements => $read_log_slow_statements,
    conn_max_age        => $read_conn_max_age,
    conn_keep_alive     => $read_conn_keep_alive,
    conn_lifetime       => $read_conn_lifetime,
    confdir             => $confdir,
    notify              => Service[$puppetdb_service],
  }

  if str2bool($ssl_set_cert_paths) == true or str2bool($ssl_deploy_certs) == true {
    validate_absolute_path($ssl_key_path)
    validate_absolute_path($ssl_cert_path)
    validate_absolute_path($ssl_ca_cert_path)
  }

  if str2bool($ssl_deploy_certs) == true {
    validate_absolute_path($ssl_dir)
    file{
      $ssl_dir:
        ensure  => directory,
        owner   => $puppetdb_user,
        group   => $puppetdb_group,
        mode    => '0700';
      $ssl_key_path:
        ensure  => file,
        content => $ssl_key,
        owner   => $puppetdb_user,
        group   => $puppetdb_group,
        mode    => '0600',
        notify  => Service[$puppetdb_service];
      $ssl_cert_path:
        ensure  => file,
        content => $ssl_cert,
        owner   => $puppetdb_user,
        group   => $puppetdb_group,
        mode    => '0600',
        notify  => Service[$puppetdb_service];
      $ssl_ca_cert_path:
        ensure  => file,
        content => $ssl_ca_cert,
        owner   => $puppetdb_user,
        group   => $puppetdb_group,
        mode    => '0600',
        notify  => Service[$puppetdb_service];
    }
  }

  class { 'puppetdb::server::jetty':
    listen_address     => $listen_address,
    listen_port        => $listen_port,
    ssl_listen_address => $ssl_listen_address,
    ssl_listen_port    => $ssl_listen_port,
    ssl_set_cert_paths => $ssl_set_cert_paths,
    ssl_key_path       => $ssl_key_path,
    ssl_cert_path      => $ssl_cert_path,
    ssl_ca_cert_path   => $ssl_ca_cert_path,
    ssl_protocols      => $ssl_protocols,
    disable_ssl        => $disable_ssl,
    confdir            => $confdir,
    max_threads        => $max_threads,
    notify             => Service[$puppetdb_service],
  }

  if !empty($java_args) {
    create_resources(
      'ini_subsetting',
      puppetdb_create_subsetting_resource_hash(
        $java_args,
        { ensure  => present,
          section => '',
          key_val_separator => '=',
          path => $puppetdb::params::puppetdb_initconf,
          setting => 'JAVA_ARGS',
          require => Package[$puppetdb_package],
          notify => Service[$puppetdb_service],
        })
    )
  }

  service { $puppetdb_service:
    ensure => $puppetdb_service_status,
    enable => $service_enabled,
  }

  if $manage_firewall {
    Package[$puppetdb_package] ->
    Class['puppetdb::server::firewall'] ->
    Class['puppetdb::server::command_processing'] ->
    Class['puppetdb::server::database'] ->
    Class['puppetdb::server::read_database'] ->
    Class['puppetdb::server::jetty'] ->
    Service[$puppetdb_service]
  } else {
    Package[$puppetdb_package] ->
    Class['puppetdb::server::command_processing'] ->
    Class['puppetdb::server::database'] ->
    Class['puppetdb::server::read_database'] ->
    Class['puppetdb::server::jetty'] ->
    Service[$puppetdb_service]
  }
}
