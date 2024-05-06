# @summary manage the PuppetDB server
#
# @param listen_address
#   The address that the web server should bind to for HTTP requests. Defaults to
#   `localhost`. Set to `0.0.0.0` to listen on all addresses.
#
# @param listen_port
#   The port on which the puppetdb web server should accept HTTP requests. Defaults
#   to `8080`.
#
# @param disable_cleartext
#   If `true`, the puppetdb web server will only serve HTTPS and not HTTP requests (defaults to false).
#
# @param open_listen_port
#   If `true`, open the `http_listen_port` on the firewall. Defaults to `false`.
#
# @param ssl_listen_address
#   The address that the web server should bind to for HTTPS requests. Defaults to
#   `0.0.0.0` to listen on all addresses.
#
# @param ssl_listen_port
#   The port on which the puppetdb web server should accept HTTPS requests. Defaults
#   to `8081`.
#
# @param disable_ssl
#   If `true`, the puppetdb web server will only serve HTTP and not HTTPS requests.
#   Defaults to `false`.
#
# @param open_ssl_listen_port
#   If true, open the `ssl_listen_port` on the firewall. Defaults to `undef`.
#
# @param ssl_protocols
#   Specify the supported SSL protocols for PuppetDB (e.g. TLSv1, TLSv1.1, TLSv1.2.)
#
# @param postgresql_ssl_on
#   If `true`, it configures SSL connections between PuppetDB and the PostgreSQL database.
#   Defaults to `false`.
#
# @param cipher_suites
#   Configure jetty's supported `cipher-suites` (e.g. `SSL_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384`).
#   Defaults to `undef`.
#
# @param migrate
#   If `true`, puppetdb will automatically migrate to the latest database format at startup. If `false`, if the database format supplied by this version of PuppetDB doesn't match the version expected (whether newer or older), PuppetDB will exit with an error status. Defaults to `true`.
#
# @param manage_database
#   If true, the PostgreSQL database will be managed by this module. Defaults to `true`.
#
# @param database_host
#   Hostname to use for the database connection. For single case installations this
#   should be left as the default. Defaults to `localhost`.
#
# @param database_port
#   The port that the database server listens on. Defaults to `5432`.
#
# @param database_username
#   The name of the database user to connect as. Defaults to `puppetdb`.
#
# @param database_password
#   The password for the database user. Defaults to `puppetdb`.
#
# @param manage_db_password
#   Whether or not the database password in database.ini will be managed by this module.
#   Set this to `false` if you want to set the password some other way.
#   Defaults to `true`
#
# @param database_name
#   The name of the database instance to connect to. Defaults to `puppetdb`.
#
# @param jdbc_ssl_properties
#   The text to append to the JDBC connection URI. This should begin with a '?'
#   character. For example, to use SSL for the PostgreSQL connection, set this
#   parameter's value to `?ssl=true`.
#
# @param database_validate
#   If true, the module will attempt to connect to the database using the specified
#   settings and fail if it is not able to do so. Defaults to `true`.
#
# @param node_ttl
#   The length of time a node can go without receiving any new data before it's
#   automatically deactivated. (defaults to '7d', which is a 7-day period. Set to
#   '0d' to disable auto-deactivation).  This option is supported in PuppetDB >=
#   1.1.0.
#
# @param node_purge_ttl
#   The length of time a node can be deactivated before it's deleted from the
#   database. (defaults to '14d', which is a 14-day period. Set to '0d' to disable
#   purging). This option is supported in PuppetDB >= 1.2.0.
#
# @param report_ttl
#   The length of time reports should be stored before being deleted. (defaults to
#   `14d`, which is a 14-day period). This option is supported in PuppetDB >= 1.1.0.
#
# @param facts_blacklist
#   A list of fact names to be ignored whenever submitted.
#
# @param gc_interval
#   This controls how often (in minutes) to compact the database. The compaction
#   process reclaims space and deletes unnecessary rows. If not supplied, the
#   default is every 60 minutes. This option is supported in PuppetDB >= 0.9.
#
# @param node_purge_gc_batch_limit
#   Nodes will be purged in batches of this size, one batch per gc-interval.
#
# @param conn_max_age
#   The maximum time (in minutes) for a pooled connection to remain unused before
#   it is closed off.
#
#   If not supplied, we default to `60` minutes. This option is supported in PuppetDB >= 1.1.
#
# @param conn_lifetime
#   The maximum time (in minutes) a pooled connection should remain open. Any
#   connections older than this setting will be closed off. Connections currently in
#   use will not be affected until they are returned to the pool.
#
#   If not supplied, we won't terminate connections based on their age alone. This
#   option is supported in PuppetDB >= 1.4.
#
# @param puppetdb_package
#   The PuppetDB package name in the package manager. Defaults to `present`.
#
# @param puppetdb_service
#   The name of the PuppetDB service. Defaults to `puppetdb`.
#
# @param puppetdb_service_status
#   Sets whether the service should be `running ` or `stopped`. When set to `stopped` the
#   service doesn't start on boot either. Valid values are `true`, `running`,
#   `false`, and `stopped`.
#
# @param puppetdb_user
#   Puppetdb service user
#
# @param puppetdb_group
#   Puppetdb service group
#
# @param confdir
#   The PuppetDB configuration directory. Defaults to `/etc/puppetdb/conf.d`.
#
# @param vardir
#   The parent directory for the MQ's data directory.
#
# @param java_args
#   Java VM options used for overriding default Java VM options specified in
#   PuppetDB package. Defaults to `{}`. See
#   [PuppetDB Configuration](https://puppet.com/docs/puppetdb/latest/configure.html)
#   to get more details about the current defaults.
#
#   For example, to set `-Xmx512m -Xms256m` options use:
#
#       {
#           '-Xmx' => '512m',
#           '-Xms' => '256m',
#       }
#
# @param merge_default_java_args
#   Sets whether the provided java args should be merged with the defaults, or
#   should override the defaults. This setting is necessary if any of the defaults
#   are to be removed. Defaults to true. If `false`, the `java_args` in the PuppetDB
#   init config file will reflect only what is passed via the `java_args` param.
#
# @param max_threads
#   Jetty option to explicitly set `max-threads`. Defaults to `undef`, so the
#   PuppetDB-Jetty default is used.
#
# @param read_database_host
#   *This parameter must be set to use another PuppetDB instance for queries.*
#
#   The hostname or IP address of the read database server. If set to `undef`, and
#   `manage_database` is set to `true`, it will use the value of the `database_host`
#   parameter. This option is supported in PuppetDB >= 1.6.
#
# @param read_database_port
#   The port that the read database server listens on. If `read_database_host`
#   is set to `undef`, and `manage_database` is set to `true`, it will use the value of
#   the `database_port` parameter. This option is supported in PuppetDB >= 1.6.
#
# @param read_database_username
#   The name of the read database user to connect as. Defaults to `puppetdb-read`. This
#   option is supported in PuppetDB >= 1.6.
#
# @param read_database_password
#   The password for the read database user. Defaults to `puppetdb-read`. This option is
#   supported in PuppetDB >= 1.6.
#
# @param manage_read_db_password
#   Whether or not the database password in read-database.ini will be managed by this module.
#   Set this to `false` if you want to set the password some other way.
#   Defaults to `true`
#
# @param read_database_jdbc_ssl_properties
#   The text to append to the JDBC connection URI. This should begin with a '?'
#   character. For example, to use SSL for the PostgreSQL connection, set this
#   parameter's value to `?ssl=true`.
#
# @param read_database_validate
#   If true, the module will attempt to connect to the database using the specified
#   settings and fail if it is not able to do so. Defaults to `true`.
#
# @param read_database_name
#   The name of the read database instance to connect to. If `read_database_host`
#   is set to `undef`, and `manage_database` is set to `true`, it will use the value of
#   the `database_name` parameter. This option is supported in PuppetDB >= 1.6.
#
# @param read_conn_max_age
#   The maximum time (in minutes) for a pooled read database connection to remain
#   unused before it is closed off.
#
#   If not supplied, we default to 60 minutes. This option is supported in PuppetDB >= 1.6.
#
# @param read_conn_lifetime
#   The maximum time (in minutes) a pooled read database connection should remain
#   open. Any connections older than this setting will be closed off. Connections
#   currently in use will not be affected until they are returned to the pool.
#
#   If not supplied, we won't terminate connections based on their age alone. This
#   option is supported in PuppetDB >= 1.6.
#
# @param ssl_dir
#   Base directory for PuppetDB SSL configuration. Defaults to `/etc/puppetdb/ssl`
#   or `/etc/puppetlabs/puppetdb/ssl` for FOSS and PE respectively.
#
# @param ssl_set_cert_paths
#   A switch to enable or disable the management of SSL certificates in your
#   `jetty.ini` configuration file.
#
# @param ssl_cert_path
#   Path to your SSL certificate for populating `jetty.ini`.
#
# @param ssl_key_pk8_path
#   Path to the SSL pk8 key for populating `jetty.ini`, will be generated from
#   the SSL key as needed automatically.
#
# @param ssl_key_path
#   Path to your SSL key for populating `jetty.ini`.
#
# @param ssl_ca_cert_path
#   Path to your SSL CA for populating `jetty.ini`.
#
# @param ssl_deploy_certs
#   A boolean switch to enable or disable the management of SSL keys in your
#   `ssl_dir`. Default is `false`.
#
# @param ssl_key
#   Contents of your SSL key, as a string.
#
# @param ssl_cert
#   Contents of your SSL certificate, as a string.
#
# @param ssl_ca_cert
#   Contents of your SSL CA certificate, as a string.
#
# @param manage_firewall
#   If `true`, puppet will manage your iptables rules for PuppetDB via the
#   [puppetlabs-firewall](https://forge.puppetlabs.com/puppetlabs/firewall) class.
#
# @param command_threads
#   The number of command processing threads to use. Defaults to `undef`, using the
#   PuppetDB built-in default.
#
# @param concurrent_writes
#   The number of threads allowed to write to disk at any one time. Defaults to
#   `undef`, which uses the PuppetDB built-in default.
#
# @param store_usage
#   The amount of disk space (in MB) to allow for persistent message storage.
#   Defaults to `undef`, using the PuppetDB built-in default.
#
# @param temp_usage
#   The amount of disk space (in MB) to allow for temporary message storage.
#   Defaults to `undef`, using the PuppetDB built-in default.
#
# @param disable_update_checking
#   Setting this to true disables checking for updated versions of PuppetDB and sending basic analytics data to Puppet.
#   Defaults to `undef`, using the PuppetDB built-in default.
#
# @param certificate_whitelist_file
#   The name of the certificate whitelist file to set up and configure in PuppetDB. Defaults to `/etc/puppetdb/certificate-whitelist` or `/etc/puppetlabs/puppetdb/certificate-whitelist` for FOSS and PE respectively.
#
# @param certificate_whitelist
#   Array of the X.509 certificate Common Names of clients allowed to connect to PuppetDB. Defaults to empty. Be aware that this permits full access to all Puppet clients to download anything contained in PuppetDB, including the full catalogs of all nodes, which possibly contain sensitive information. Set to `[ $::servername ]` to allow access only from your (single) Puppet master, which is enough for normal operation. Set to a list of Puppet masters if you have multiple.
#
# @param database_max_pool_size
#   When the pool reaches this size, and no idle connections are available, attempts to get a connection will wait for connection-timeout milliseconds before timing out.
#   Note that PuppetDB will use one pool for writes and another for reads, so the total number of connections used will be twice this setting.
#
# @param read_database_max_pool_size
#   When the pool reaches this size, and no idle connections are available, attempts to get a connection will wait for connection-timeout milliseconds before timing out.
#   Note that PuppetDB will use one pool for writes and another for reads, so the total number of connections used will be twice this setting.
#
# @param automatic_dlo_cleanup
#   PuppetDB creates [Dead Letter Office](https://puppet.com/docs/puppetdb/5.2/maintain_and_tune.html#clean-up-the-dead-letter-office).
#   Those are reports of failed requests. They spill up the disk. This parameter is
#   a boolean and defaults to false. You can enable automatic cleanup of DLO
#   reports by setting this to true.
#
# @param cleanup_timer_interval
#   The DLO cleanup is a systemd timer if systemd is available, otherwise a
#   cronjob. The variable configures the systemd.timer option [onCalender](https://www.freedesktop.org/software/systemd/man/systemd.timer.html#OnCalendar=).
#   It defaults to `*-*-* ${fqdn_rand(24)}:${fqdn_rand(60)}:00`. This will start
#   the cleanup service on a daily basis. The exact minute and hour is random
#   per node based on the [fqdn_rand](https://puppet.com/docs/puppet/5.5/function.html#fqdnrand)
#   method. On non-systemd systems, the cron runs daily and the `$puppetdb_user` needs
#   to be able to run cron jobs. On systemd systems you need the [camptocamp/systemd](https://forge.puppet.com/camptocamp/systemd)
#   module, which is an optional dependency and not automatically installed!
#
# @param dlo_max_age
#   This is a positive integer. It describes the amount of days you want to keep
#   the DLO reports. The default value is 90 days.
#
# @param java_bin
#   java binary path for PuppetDB. If undef, default will be used.
#
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
  $database_host                           = $puppetdb::params::database_host,
  $database_port                           = $puppetdb::params::database_port,
  $database_username                       = $puppetdb::params::database_username,
  $database_password                       = $puppetdb::params::database_password,
  $database_name                           = $puppetdb::params::database_name,
  $manage_db_password                      = $puppetdb::params::manage_db_password,
  $jdbc_ssl_properties                     = $puppetdb::params::jdbc_ssl_properties,
  $database_validate                       = $puppetdb::params::database_validate,
  $node_ttl                                = $puppetdb::params::node_ttl,
  $node_purge_ttl                          = $puppetdb::params::node_purge_ttl,
  $report_ttl                              = $puppetdb::params::report_ttl,
  Optional[Array] $facts_blacklist         = $puppetdb::params::facts_blacklist,
  $gc_interval                             = $puppetdb::params::gc_interval,
  $node_purge_gc_batch_limit               = $puppetdb::params::node_purge_gc_batch_limit,
  $conn_max_age                            = $puppetdb::params::conn_max_age,
  $conn_lifetime                           = $puppetdb::params::conn_lifetime,
  $puppetdb_package                        = $puppetdb::params::puppetdb_package,
  $puppetdb_service                        = $puppetdb::params::puppetdb_service,
  $puppetdb_service_status                 = $puppetdb::params::puppetdb_service_status,
  $puppetdb_user                           = $puppetdb::params::puppetdb_user,
  $puppetdb_group                          = $puppetdb::params::puppetdb_group,
  $read_database_host                      = $puppetdb::params::read_database_host,
  $read_database_port                      = $puppetdb::params::read_database_port,
  $read_database_username                  = $puppetdb::params::read_database_username,
  $read_database_password                  = $puppetdb::params::read_database_password,
  $read_database_name                      = $puppetdb::params::read_database_name,
  $manage_read_db_password                 = $puppetdb::params::manage_read_db_password,
  $read_database_jdbc_ssl_properties       = $puppetdb::params::read_database_jdbc_ssl_properties,
  $read_database_validate                  = $puppetdb::params::read_database_validate,
  $read_conn_max_age                       = $puppetdb::params::read_conn_max_age,
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
    node_ttl                  => $node_ttl,
    node_purge_ttl            => $node_purge_ttl,
    report_ttl                => $report_ttl,
    facts_blacklist           => $facts_blacklist,
    gc_interval               => $gc_interval,
    node_purge_gc_batch_limit => $node_purge_gc_batch_limit,
    conn_max_age              => $conn_max_age,
    conn_lifetime             => $conn_lifetime,
    confdir                   => $confdir,
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
    conn_max_age           => $read_conn_max_age,
    conn_lifetime          => $read_conn_lifetime,
    confdir                => $confdir,
    puppetdb_group         => $puppetdb_group,
    notify                 => Service[$puppetdb_service],
    database_max_pool_size => $read_database_max_pool_size,
  }

  if $ssl_deploy_certs {
    file {
      $ssl_dir:
        ensure => directory,
        owner  => 'root',
        group  => $puppetdb_group,
        mode   => '0755';
      $ssl_key_path:
        ensure  => file,
        content => $ssl_key,
        owner   => 'root',
        group   => $puppetdb_group,
        mode    => '0640',
        notify  => Service[$puppetdb_service];
      $ssl_cert_path:
        ensure  => file,
        content => $ssl_cert,
        owner   => 'root',
        group   => $puppetdb_group,
        mode    => '0644',
        notify  => Service[$puppetdb_service];
      $ssl_ca_cert_path:
        ensure  => file,
        content => $ssl_ca_cert,
        owner   => 'root',
        group   => $puppetdb_group,
        mode    => '0644',
        notify  => Service[$puppetdb_service];
    }
  }

  if $postgresql_ssl_on {
    exec { $ssl_key_pk8_path:
      path    => ['/opt/puppetlabs/puppet/bin', $facts['path']],
      command => "openssl pkcs8 -topk8 -inform PEM -outform DER -in ${ssl_key_path} -out ${ssl_key_pk8_path} -nocrypt",
      # Generate a .pk8 key if one doesn't exist or is older than the .pem input.
      # NOTE: bash file time checks, like -ot, can't always discern sub-second
      # differences.
      onlyif  => "test ! -e '${ssl_key_pk8_path}' -o '${ssl_key_pk8_path}' -ot '${ssl_key_path}'",
      before  => File[$ssl_key_pk8_path],
    }

    file { $ssl_key_pk8_path:
      ensure => file,
      owner  => 'root',
      group  => $puppetdb_group,
      mode   => '0640',
      notify => Service[$puppetdb_service],
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
    puppetdb_group     => $puppetdb_group,
  }

  class { 'puppetdb::server::puppetdb':
    certificate_whitelist_file => $certificate_whitelist_file,
    certificate_whitelist      => $certificate_whitelist,
    disable_update_checking    => $disable_update_checking,
    confdir                    => $confdir,
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
        content => epp("${module_name}/puppetdb-DLO-cleanup.timer.epp", { 'cleanup_timer_interval' => $cleanup_timer_interval }),
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
        require  => Package[$puppetdb_package],
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
