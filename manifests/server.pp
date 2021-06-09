# Class to configure a PuppetDB server. See README.md for more details.
class puppetdb::server (
  $listen_address                          = $puppetdb::params::listen_address,
  $listen_port                             = $puppetdb::params::listen_port,
  $disable_cleartext                       = $puppetdb::params::disable_cleartext,
  $open_listen_port                        = $puppetdb::params::open_listen_port,
  $ssl_listen_address                      = $puppetdb::params::ssl_listen_address,
  $ssl_listen_port                         = $puppetdb::params::ssl_listen_port,
  $disable_ssl                             = $puppetdb::params::disable_ssl,
  $open_ssl_listen_port                    = $puppetdb::params::open_ssl_listen_port,
  Stdlib::Absolutepath $ssl_dir            = $puppetdb::params::ssl_dir,
  Boolean $ssl_set_cert_paths              = $puppetdb::params::ssl_set_cert_paths,
  Stdlib::Absolutepath $ssl_cert_path      = $puppetdb::params::ssl_cert_path,
  Stdlib::Absolutepath $ssl_key_path       = $puppetdb::params::ssl_key_path,
  Stdlib::Absolutepath $ssl_key_pk8_path   = $puppetdb::params::ssl_key_pk8_path,
  Stdlib::Absolutepath $ssl_ca_cert_path   = $puppetdb::params::ssl_ca_cert_path,
  Boolean $ssl_deploy_certs                = $puppetdb::params::ssl_deploy_certs,
  $ssl_key                                 = $puppetdb::params::ssl_key,
  $ssl_cert                                = $puppetdb::params::ssl_cert,
  $ssl_ca_cert                             = $puppetdb::params::ssl_ca_cert,
  $ssl_protocols                           = $puppetdb::params::ssl_protocols,
  $postgresql_ssl_on                       = $puppetdb::params::postgresql_ssl_on,
  $cipher_suites                           = $puppetdb::params::cipher_suites,
  $migrate                                 = $puppetdb::params::migrate,
  $database                                = $puppetdb::params::database,
  $database_host                           = $puppetdb::params::database_host,
  $database_port                           = $puppetdb::params::database_port,
  $database_username                       = $puppetdb::params::database_username,
  $database_password                       = $puppetdb::params::database_password,
  $database_name                           = $puppetdb::params::database_name,
  $manage_db_password                      = $puppetdb::params::manage_db_password,
  $jdbc_ssl_properties                     = $puppetdb::params::jdbc_ssl_properties,
  $database_validate                       = $puppetdb::params::database_validate,
  $database_embedded_path                  = $puppetdb::params::database_embedded_path,
  $node_ttl                                = $puppetdb::params::node_ttl,
  $node_purge_ttl                          = $puppetdb::params::node_purge_ttl,
  $report_ttl                              = $puppetdb::params::report_ttl,
  Optional[Array] $facts_blacklist         = $puppetdb::params::facts_blacklist,
  $gc_interval                             = $puppetdb::params::gc_interval,
  $node_purge_gc_batch_limit               = $puppetdb::params::node_purge_gc_batch_limit,
  $log_slow_statements                     = $puppetdb::params::log_slow_statements,
  $conn_max_age                            = $puppetdb::params::conn_max_age,
  $conn_keep_alive                         = $puppetdb::params::conn_keep_alive,
  $conn_lifetime                           = $puppetdb::params::conn_lifetime,
  $puppetdb_package                        = $puppetdb::params::puppetdb_package,
  $puppetdb_service                        = $puppetdb::params::puppetdb_service,
  $puppetdb_service_status                 = $puppetdb::params::puppetdb_service_status,
  $puppetdb_user                           = $puppetdb::params::puppetdb_user,
  $puppetdb_group                          = $puppetdb::params::puppetdb_group,
  $read_database                           = $puppetdb::params::read_database,
  $read_database_host                      = $puppetdb::params::read_database_host,
  $read_database_port                      = $puppetdb::params::read_database_port,
  $read_database_username                  = $puppetdb::params::read_database_username,
  $read_database_password                  = $puppetdb::params::read_database_password,
  $read_database_name                      = $puppetdb::params::read_database_name,
  $manage_read_db_password                 = $puppetdb::params::manage_read_db_password,
  $read_database_jdbc_ssl_properties       = $puppetdb::params::read_database_jdbc_ssl_properties,
  $read_database_validate                  = $puppetdb::params::read_database_validate,
  $read_log_slow_statements                = $puppetdb::params::read_log_slow_statements,
  $read_conn_max_age                       = $puppetdb::params::read_conn_max_age,
  $read_conn_keep_alive                    = $puppetdb::params::read_conn_keep_alive,
  $read_conn_lifetime                      = $puppetdb::params::read_conn_lifetime,
  $confdir                                 = $puppetdb::params::confdir,
  $vardir                                  = $puppetdb::params::vardir,
  $manage_firewall                         = $puppetdb::params::manage_firewall,
  $manage_database                         = $puppetdb::params::manage_database,
  $java_args                               = $puppetdb::params::java_args,
  $merge_default_java_args                 = $puppetdb::params::merge_default_java_args,
  $max_threads                             = $puppetdb::params::max_threads,
  $command_threads                         = $puppetdb::params::command_threads,
  $concurrent_writes                       = $puppetdb::params::concurrent_writes,
  $store_usage                             = $puppetdb::params::store_usage,
  $temp_usage                              = $puppetdb::params::temp_usage,
  $disable_update_checking                 = $puppetdb::params::disable_update_checking,
  $certificate_whitelist_file              = $puppetdb::params::certificate_whitelist_file,
  $certificate_whitelist                   = $puppetdb::params::certificate_whitelist,
  $database_max_pool_size                  = $puppetdb::params::database_max_pool_size,
  $read_database_max_pool_size             = $puppetdb::params::read_database_max_pool_size,
  Boolean $automatic_dlo_cleanup           = $puppetdb::params::automatic_dlo_cleanup,
  String[1] $cleanup_timer_interval        = $puppetdb::params::cleanup_timer_interval,
  Integer[1] $dlo_max_age                  = $puppetdb::params::dlo_max_age,
  Optional[Stdlib::Absolutepath] $java_bin = $puppetdb::params::java_bin,
) inherits puppetdb::params {

  # Apply necessary suffix if zero is specified.
  # Can we drop this in the next major release?
  if $node_ttl == '0' {
    $_node_ttl_real = '0s'
  } else {
    $_node_ttl_real = downcase($node_ttl)
  }

  # Validate node_ttl
  $node_ttl_real = assert_type(Puppetdb::Ttl, $_node_ttl_real)

  # Apply necessary suffix if zero is specified.
  # Can we drop this in the next major release?
  if $node_purge_ttl == '0' {
    $_node_purge_ttl_real = '0s'
  } else {
    $_node_purge_ttl_real = downcase($node_purge_ttl)
  }

  # Validate node_purge_ttl
  $node_purge_ttl_real = assert_type(Puppetdb::Ttl, $_node_purge_ttl_real)

  # Apply necessary suffix if zero is specified.
  # Can we drop this in the next major release?
  if $report_ttl == '0' {
    $_report_ttl_real = '0s'
  } else {
    $_report_ttl_real = downcase($report_ttl)
  }

  # Validate report_ttl
  $repor_ttl_real = assert_type(Puppetdb::Ttl, $_report_ttl_real)

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

  class { 'puppetdb::server::global':
    vardir         => $vardir,
    confdir        => $confdir,
    puppetdb_user  => $puppetdb_user,
    puppetdb_group => $puppetdb_group,
    notify         => Service[$puppetdb_service],
  }

  class { 'puppetdb::server::command_processing':
    command_threads   => $command_threads,
    concurrent_writes => $concurrent_writes,
    store_usage       => $store_usage,
    temp_usage        => $temp_usage,
    confdir           => $confdir,
    notify            => Service[$puppetdb_service],
  }

  class { 'puppetdb::server::database':
    database                  => $database,
    database_host             => $database_host,
    database_port             => $database_port,
    database_username         => $database_username,
    database_password         => $database_password,
    database_name             => $database_name,
    manage_db_password        => $manage_db_password,
    postgresql_ssl_on         => $postgresql_ssl_on,
    ssl_key_pk8_path          => $ssl_key_pk8_path,
    ssl_cert_path             => $ssl_cert_path,
    ssl_ca_cert_path          => $ssl_ca_cert_path,
    database_max_pool_size    => $database_max_pool_size,
    jdbc_ssl_properties       => $jdbc_ssl_properties,
    database_validate         => $database_validate,
    database_embedded_path    => $database_embedded_path,
    node_ttl                  => $node_ttl,
    node_purge_ttl            => $node_purge_ttl,
    report_ttl                => $report_ttl,
    facts_blacklist           => $facts_blacklist,
    gc_interval               => $gc_interval,
    node_purge_gc_batch_limit => $node_purge_gc_batch_limit,
    log_slow_statements       => $log_slow_statements,
    conn_max_age              => $conn_max_age,
    conn_keep_alive           => $conn_keep_alive,
    conn_lifetime             => $conn_lifetime,
    confdir                   => $confdir,
    puppetdb_user             => $puppetdb_user,
    puppetdb_group            => $puppetdb_group,
    migrate                   => $migrate,
    notify                    => Service[$puppetdb_service],
  }

  if $manage_database and $read_database_host == undef {
    $real_database_host = $database_host
    $real_database_port = $database_port
    $real_database_name = $database_name
  } else {
    $real_database_host =  $read_database_host
    $real_database_port =  $read_database_port
    $real_database_name =  $read_database_name
  }

  class { 'puppetdb::server::read_database':
    read_database          => $read_database,
    read_database_host     => $real_database_host,
    read_database_port     => $real_database_port,
    read_database_username => $read_database_username,
    read_database_password => $read_database_password,
    read_database_name     => $real_database_name,
    manage_db_password     => $manage_read_db_password,
    postgresql_ssl_on      => $postgresql_ssl_on,
    ssl_key_pk8_path       => $ssl_key_pk8_path,
    ssl_cert_path          => $ssl_cert_path,
    ssl_ca_cert_path       => $ssl_ca_cert_path,
    jdbc_ssl_properties    => $read_database_jdbc_ssl_properties,
    database_validate      => $read_database_validate,
    log_slow_statements    => $read_log_slow_statements,
    conn_max_age           => $read_conn_max_age,
    conn_keep_alive        => $read_conn_keep_alive,
    conn_lifetime          => $read_conn_lifetime,
    confdir                => $confdir,
    puppetdb_user          => $puppetdb_user,
    puppetdb_group         => $puppetdb_group,
    notify                 => Service[$puppetdb_service],
    database_max_pool_size => $read_database_max_pool_size,
  }

  if $ssl_deploy_certs {
    file {
      $ssl_dir:
        ensure => directory,
        owner  => $puppetdb_user,
        group  => $puppetdb_group,
        mode   => '0700';
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

  if $postgresql_ssl_on {
    exec { $ssl_key_pk8_path:
      path    => [ '/opt/puppetlabs/puppet/bin', $facts['path'] ],
      command => "openssl pkcs8 -topk8 -inform PEM -outform DER -in ${ssl_key_path} -out ${ssl_key_pk8_path} -nocrypt",
      # Generate a .pk8 key if one doesn't exist or is older than the .pem input.
      # NOTE: bash file time checks, like -ot, can't always discern sub-second
      # differences.
      onlyif  => "test ! -e '${ssl_key_pk8_path}' -o '${ssl_key_pk8_path}' -ot '${ssl_key_path}'",
      before  => File[$ssl_key_pk8_path]
    }

    file { $ssl_key_pk8_path:
      ensure => present,
      owner  => $puppetdb_user,
      group  => $puppetdb_group,
      mode   => '0600',
      notify => Service[$puppetdb_service]
    }
  }

  class { 'puppetdb::server::jetty':
    listen_address     => $listen_address,
    listen_port        => $listen_port,
    disable_cleartext  => $disable_cleartext,
    ssl_listen_address => $ssl_listen_address,
    ssl_listen_port    => $ssl_listen_port,
    ssl_set_cert_paths => $ssl_set_cert_paths,
    ssl_key_path       => $ssl_key_path,
    ssl_cert_path      => $ssl_cert_path,
    ssl_ca_cert_path   => $ssl_ca_cert_path,
    ssl_protocols      => $ssl_protocols,
    cipher_suites      => $cipher_suites,
    disable_ssl        => $disable_ssl,
    confdir            => $confdir,
    max_threads        => $max_threads,
    notify             => Service[$puppetdb_service],
    puppetdb_user      => $puppetdb_user,
    puppetdb_group     => $puppetdb_group,
  }

  class { 'puppetdb::server::puppetdb':
    certificate_whitelist_file => $certificate_whitelist_file,
    certificate_whitelist      => $certificate_whitelist,
    disable_update_checking    => $disable_update_checking,
    confdir                    => $confdir,
    puppetdb_user              => $puppetdb_user,
    puppetdb_group             => $puppetdb_group,
    notify                     => Service[$puppetdb_service],
  }

  if !empty($java_args) {
    if $merge_default_java_args {
      create_resources(
        'ini_subsetting',
        puppetdb::create_subsetting_resource_hash(
          $java_args, {
            ensure            => present,
            section           => '',
            key_val_separator => '=',
            path              => $puppetdb::params::puppetdb_initconf,
            setting           => 'JAVA_ARGS',
            require           => Package[$puppetdb_package],
            notify            => Service[$puppetdb_service],
          }))
    } else {
      ini_setting { 'java_args':
        ensure  => present,
        section => '',
        path    => $puppetdb::params::puppetdb_initconf,
        setting => 'JAVA_ARGS',
        require => Package[$puppetdb_package],
        notify  => Service[$puppetdb_service],
        value   => puppetdb::flatten_java_args($java_args),
      }
    }
  }

  # java binary path for PuppetDB. If undef, default will be used.
  if $java_bin {
    ini_setting { 'java':
      ensure  => 'present',
      section => '',
      path    => $puppetdb::params::puppetdb_initconf,
      setting => 'JAVA_BIN',
      require => Package[$puppetdb_package],
      notify  => Service[$puppetdb_service],
      value   => $java_bin,
    }
  }

  if $automatic_dlo_cleanup {
    if $facts['systemd'] {
      # deploy a systemd timer + service to cleanup old reports
      # https://puppet.com/docs/puppetdb/5.2/maintain_and_tune.html#clean-up-the-dead-letter-office
      systemd::unit_file { 'puppetdb-dlo-cleanup.service':
        content => epp("${module_name}/puppetdb-DLO-cleanup.service.epp", {
          'puppetdb_user'  => $puppetdb_user,
          'puppetdb_group' => $puppetdb_group,
          'vardir'         => $vardir,
          'dlo_max_age'    => $dlo_max_age
        }),
      }
      -> systemd::unit_file { 'puppetdb-dlo-cleanup.timer':
        content => epp("${module_name}/puppetdb-DLO-cleanup.timer.epp", {'cleanup_timer_interval' => $cleanup_timer_interval }),
        enable  => true,
        active  => true,
      }
    } else {
      cron { 'puppetdb-dlo-cleanup':
        ensure   => 'present',
        minute   => fqdn_rand(60),
        hour     => fqdn_rand(24),
        monthday => '*',
        month    => '*',
        weekday  => '*',
        command  => "/usr/bin/find ${vardir}/stockpile/discard/ -type f -mtime ${dlo_max_age} -delete",
        user     => $puppetdb_user,
      }
    }
  }

  service { $puppetdb_service:
    ensure => $puppetdb_service_status,
    enable => $service_enabled,
  }

  if $manage_firewall {
    Package[$puppetdb_package]
    -> Class['puppetdb::server::firewall']
    -> Class['puppetdb::server::global']
    -> Class['puppetdb::server::command_processing']
    -> Class['puppetdb::server::database']
    -> Class['puppetdb::server::read_database']
    -> Class['puppetdb::server::jetty']
    -> Class['puppetdb::server::puppetdb']
    -> Service[$puppetdb_service]
  } else {
    Package[$puppetdb_package]
    -> Class['puppetdb::server::global']
    -> Class['puppetdb::server::command_processing']
    -> Class['puppetdb::server::database']
    -> Class['puppetdb::server::read_database']
    -> Class['puppetdb::server::jetty']
    -> Class['puppetdb::server::puppetdb']
    -> Service[$puppetdb_service]
  }
}
