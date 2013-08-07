# This class provides a simple way to get a puppetdb instance up and running
# with minimal effort.  It will install and configure all necessary packages for
# the puppetdb server, but will *not* manage the database (e.g., postgres) server
# or instance (unless you are using the embedded database, in which case there
# is not much to manage).
#
# This class is intended as a high-level abstraction to help simplify the process
# of getting your puppetdb server up and running; it manages the puppetdb
# package and service, as well as several puppetdb configuration files.  For
# maximum configurability, you may choose not to use this class.  You may prefer to
# manage the puppetdb package / service on your own, and perhaps use the
# individual classes inside of the `puppetdb::server` namespace to manage some
# or all of your configuration files.
#
# In addition to this class, you'll need to configure your puppetdb postgres
# database if you are using postgres.  You can optionally do by using the
# `puppetdb::database::postgresql` class.
#
# You'll also need to configure your puppet master to use puppetdb.  You can
# use the `puppetdb::master::config` class to accomplish this.
class puppetdb::server(
  $listen_address          = $puppetdb::params::listen_address,
  $listen_port             = $puppetdb::params::listen_port,
  $open_listen_port        = $puppetdb::params::open_listen_port,
  $ssl_listen_address      = $puppetdb::params::ssl_listen_address,
  $ssl_listen_port         = $puppetdb::params::ssl_listen_port,
  $disable_ssl             = $puppetdb::params::disable_ssl,
  $open_ssl_listen_port    = $puppetdb::params::open_ssl_listen_port,
  $database                = $puppetdb::params::database,
  $database_host           = $puppetdb::params::database_host,
  $database_port           = $puppetdb::params::database_port,
  $database_username       = $puppetdb::params::database_username,
  $database_password       = $puppetdb::params::database_password,
  $database_name           = $puppetdb::params::database_name,
  $node_ttl                = $puppetdb::params::node_ttl,
  $node_purge_ttl          = $puppetdb::params::node_purge_ttl,
  $report_ttl              = $puppetdb::params::report_ttl,
  $gc_interval             = $puppetdb::params::gc_interval,
  $log_slow_statements     = $puppetdb::params::log_slow_statements,
  $conn_max_age            = $puppetdb::params::conn_max_age,
  $conn_keep_alive         = $puppetdb::params::conn_keep_alive,
  $conn_lifetime           = $puppetdb::params::lifetime,
  $puppetdb_package        = $puppetdb::params::puppetdb_package,
  $puppetdb_version        = $puppetdb::params::puppetdb_version,
  $puppetdb_service        = $puppetdb::params::puppetdb_service,
  $manage_redhat_firewall  = $puppetdb::params::manage_redhat_firewall,
  $confdir                 = $puppetdb::params::confdir,
  $java_args               = {}
) inherits puppetdb::params {

  # Apply necessary suffix if zero is specified.
  if $node_ttl == '0' {
    $node_ttl_real = '0s'
  } else {
    $node_ttl_real = downcase($node_ttl)
  }

  # Validate node_ttl
  validate_re ($node_ttl_real, ['^(\d)+[s,m,d]$'], "node_ttl is <${node_ttl}> which does not match the regex validation")

  # Apply necessary suffix if zero is specified.
  if $node_purge_ttl == '0' {
    $node_purge_ttl_real = '0s'
  } else {
    $node_purge_ttl_real = downcase($node_purge_ttl)
  }

  # Validate node_purge_ttl
  validate_re ($node_purge_ttl_real, ['^(\d)+[s,m,d]$'], "node_purge_ttl is <${node_purge_ttl}> which does not match the regex validation")

  # Apply necessary suffix if zero is specified.
  if $report_ttl == '0' {
    $report_ttl_real = '0s'
  } else {
    $report_ttl_real = downcase($report_ttl)
  }

  # Validate report_ttl
  validate_re ($report_ttl_real, ['^(\d)+[s,m,d]$'], "report_ttl is <${report_ttl}> which does not match the regex validation")

  package { $puppetdb_package:
    ensure => $puppetdb_version,
    notify => Service[$puppetdb_service],
  }

  class { 'puppetdb::server::firewall':
    http_port              => $listen_port,
    open_http_port         => $open_listen_port,
    ssl_port               => $ssl_listen_port,
    open_ssl_port          => $open_ssl_listen_port,
    manage_redhat_firewall => $manage_redhat_firewall
  }

  class { 'puppetdb::server::database_ini':
    database          => $database,
    database_host     => $database_host,
    database_port     => $database_port,
    database_username => $database_username,
    database_password => $database_password,
    database_name     => $database_name,
    node_ttl          => $node_ttl,
    node_purge_ttl    => $node_purge_ttl,
    report_ttl        => $report_ttl,
    gc_interval       => $gc_interval,
    log_slow_statements => $log_slow_statements,
    conn_max_age      => $conn_max_age,
    conn_keep_alive   => $conn_keep_alive,
    conn_lifetime     => $conn_lifetime,
    confdir           => $confdir,
    notify            => Service[$puppetdb_service],
  }

  class { 'puppetdb::server::jetty_ini':
    listen_address      => $listen_address,
    listen_port         => $listen_port,
    ssl_listen_address  => $ssl_listen_address,
    ssl_listen_port     => $ssl_listen_port,
    disable_ssl         => $disable_ssl,
    confdir             => $confdir,
    notify              => Service[$puppetdb_service],
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
    ensure => running,
    enable => true,
  }

  Package[$puppetdb_package] ->
  Class['puppetdb::server::firewall'] ->
  Class['puppetdb::server::database_ini'] ->
  Class['puppetdb::server::jetty_ini'] ->
  Service[$puppetdb_service]
}
