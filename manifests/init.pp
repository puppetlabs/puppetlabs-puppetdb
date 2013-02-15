# Class: puppetdb
#
# This class provides a simple way to get a puppetdb instance up and running
# with minimal effort.  It will install and configure all necessary packages,
# including the database server and instance.
#
# This class is intended as a high-level abstraction to help simplify the process
# of getting your puppetdb server up and running; it wraps the slightly-lower-level
# classes `puppetdb::server` and `puppetdb::database::*`.  For maximum
# configurability, you may choose not to use this class.  You may prefer to
# use the `puppetdb::server` class directly, or manage your puppetdb setup on your
# own.
#
# In addition to this class, you'll need to configure your puppet master to use
# puppetdb.  You can use the `puppetdb::master::config` class to accomplish this.
#
# Parameters:
#   ['listen_address']     - The address that the web server should bind to
#                            for HTTP requests.  (defaults to `localhost`.
#                            '0.0.0.0' = all)
#   ['listen_port']        - The port on which the puppetdb web server should
#                            accept HTTP requests (defaults to 8080).
#   ['open_listen_port']   - If true, open the http listen port on the firewall.
#                            (defaults to false).
#   ['ssl_listen_address'] - The address that the web server should bind to
#                            for HTTPS requests.  (defaults to `$::clientcert`.)
#                            Set to '0.0.0.0' to listen on all addresses.
#   ['ssl_listen_port']    - The port on which the puppetdb web server should
#                            accept HTTPS requests (defaults to 8081).
#   ['disable_ssl']        - If true, disable HTTPS and only serve
#                            HTTP requests. Defaults to false.
#   ['open_ssl_listen_port'] - If true, open the ssl listen port on the firewall.
#                            (defaults to true).
#   ['database']           - Which database backend to use; legal values are
#                            `postgres` (default) or `embedded`.  (The `embedded`
#                            db can be used for very small installations or for
#                            testing, but is not recommended for use in production
#                            environments.  For more info, see the puppetdb docs.)
#   ['database_port']      - The port that the database server listens on.
#                            (defaults to `5432`; ignored for `embedded` db)
#   ['database_username']  - The name of the database user to connect as.
#                            (defaults to `puppetdb`; ignored for `embedded` db)
#   ['database_password']  - The password for the database user.
#                            (defaults to `puppetdb`; ignored for `embedded` db)
#   ['database_name']      - The name of the database instance to connect to.
#                            (defaults to `puppetdb`; ignored for `embedded` db)
#   ['node_ttl']           - The length of time a node can go without receiving
#                            any new data before it's automatically deactivated.
#                            (defaults to '0', which disables auto-deactivation)
#                            This option is supported in PuppetDB >= 1.1.0.
#   ['node_purge_ttl']     - The length of time a node can be deactivated before
#                            it's deleted from the database.
#                            (defaults to '0', which disables purging)
#                            This option is supported in PuppetDB >= 1.2.0.
#   ['report_ttl']         - The length of time reports should be stored before
#                            being deleted.
#                            (defaults to '7d', which is a 7-day period)
#                            This option is supported in PuppetDB >= 1.1.0.
#   ['open_postgres_port'] - If true, open the postgres port on the firewall.
#                            (defaults to true).
#   ['puppetdb_package']   - The puppetdb package name in the package manager
#   ['puppetdb_version']   - The version of the `puppetdb` package that should
#                            be installed.  You may specify an explicit version
#                            number, 'present', or 'latest'.  (defaults to
#                            'present')
#   ['puppetdb_service']   - The name of the puppetdb service.
#   ['manage_redhat_firewall'] - DEPRECATED: Use open_ssl_listen_port instead.
#                            boolean indicating whether or not the module
#                            should open a port in the firewall on redhat-based
#                            systems.  Defaults to `false`.  This parameter is
#                            likely to change in future versions.  Possible
#                            changes include support for non-RedHat systems and
#                            finer-grained control over the firewall rule
#                            (currently, it simply opens up the postgres port to
#                            all TCP connections).
#   ['confdir']            - The puppetdb configuration directory; defaults to
#                            `/etc/puppetdb/conf.d`.
#   ['java_args']          - Java VM options used for overriding default Java VM
#                            options specified in PuppetDB package.
#                            (defaults to `{}`).
#                            e.g. { '-Xmx' => '512m', '-Xms' => '256m' }
# Actions:
# - Creates and manages a puppetdb server and its database server/instance.
#
# Requires:
# - `inkling/postgresql`
#
# Sample Usage:
#   include puppetdb
#
class puppetdb(
  $listen_address            = $puppetdb::params::listen_address,
  $listen_port               = $puppetdb::params::listen_port,
  $open_listen_port          = $puppetdb::params::open_listen_port,
  $ssl_listen_address        = $puppetdb::params::ssl_listen_address,
  $ssl_listen_port           = $puppetdb::params::ssl_listen_port,
  $disable_ssl               = $puppetdb::params::disable_ssl,
  $open_ssl_listen_port      = $puppetdb::params::open_ssl_listen_port,
  $database                  = $puppetdb::params::database,
  $database_port             = $puppetdb::params::database_port,
  $database_username         = $puppetdb::params::database_username,
  $database_password         = $puppetdb::params::database_password,
  $database_name             = $puppetdb::params::database_name,
  $node_ttl                  = $puppetdb::params::node_ttl,
  $node_purge_ttl            = $puppetdb::params::node_purge_ttl,
  $report_ttl                = $puppetdb::params::report_ttl,
  $puppetdb_package          = $puppetdb::params::puppetdb_package,
  $puppetdb_version          = $puppetdb::params::puppetdb_version,
  $puppetdb_service          = $puppetdb::params::puppetdb_service,
  $open_postgres_port        = $puppetdb::params::open_postgres_port,
  $manage_redhat_firewall    = $puppetdb::params::manage_redhat_firewall,
  $confdir                   = $puppetdb::params::confdir,
  $java_args                 = {}
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

  if ($manage_redhat_firewall != undef) {
    notify {'Deprecation notice: `$manage_redhat_firewall` has been deprecated in `puppetdb` class and will be removed in a future version. Use $open_ssl_listen_port and $open_postgres_port instead.':}
  }

  class { 'puppetdb::server':
    listen_address         => $listen_address,
    listen_port            => $listen_port,
    open_listen_port       => $open_listen_port,
    ssl_listen_address     => $ssl_listen_address,
    ssl_listen_port        => $ssl_listen_port,
    disable_ssl            => $disable_ssl,
    open_ssl_listen_port   => $open_ssl_listen_port,
    database               => $database,
    database_port          => $database_port,
    database_username      => $database_username,
    database_password      => $database_password,
    database_name          => $database_name,
    node_ttl               => $node_ttl,
    node_purge_ttl         => $node_purge_ttl,
    report_ttl             => $report_ttl,
    puppetdb_package       => $puppetdb_package,
    puppetdb_version       => $puppetdb_version,
    puppetdb_service       => $puppetdb_service,
    manage_redhat_firewall => $manage_redhat_firewall,
    confdir                => $confdir,
    java_args               => $java_args,
  }

  if ($database == 'postgres') {
    class { 'puppetdb::database::postgresql':
      manage_redhat_firewall => $manage_redhat_firewall ? {
        true                 => $manage_redhat_firewall,
        false                => $manage_redhat_firewall,
        undef                => $open_postgres_port,
      },
      listen_addresses       => $puppetdb::params::postgres_listen_addresses,
      database_name          => $database_name,
      database_username      => $database_username,
      database_password      => $database_password,
      before                 => Class['puppetdb::server']
    }
  }
}
