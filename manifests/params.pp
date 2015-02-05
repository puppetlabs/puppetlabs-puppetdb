# PRIVATE CLASS - do not use directly
#
# The puppetdb default configuration settings.
class puppetdb::params {
  $listen_address            = 'localhost'
  $listen_port               = '8080'
  $open_listen_port          = false
  $ssl_listen_address        = $::fqdn
  $ssl_listen_port           = '8081'
  $ssl_protocols             = undef
  $disable_ssl               = false
  $open_ssl_listen_port      = undef
  $postgres_listen_addresses = 'localhost'

  $database                  = 'postgres'
  $manage_db                 = true
  $manage_dbserver           = true

  # The remaining database settings are not used for an embedded database
  $database_host      = 'localhost'
  $database_port      = '5432'
  $database_name      = 'puppetdb'
  $database_username  = 'puppetdb'
  $database_password  = 'puppetdb'
  $database_ssl       = false
  $database_validate  = true
  $postgres_version   = '9.4'
  $manage_pg_repo     = false

  # These settings manage the various auto-deactivation and auto-purge settings
  $node_ttl               = '0s'
  $node_purge_ttl         = '0s'
  $report_ttl             = '14d'

  $puppetdb_version       = 'present'

  $gc_interval            = '60'

  $log_slow_statements    = '10'
  $conn_max_age           = '60'
  $conn_keep_alive        = '45'
  $conn_lifetime          = '0'

  $max_threads            = undef

  # These settings are for the read database
  $read_database            = 'postgres'
  $read_database_host       = undef
  $read_database_port       = '5432'
  $read_database_name       = 'puppetdb'
  $read_database_username   = 'puppetdb'
  $read_database_password   = 'puppetdb'
  $read_database_ssl        = false
  $read_database_validate   = true
  $read_log_slow_statements = '10'
  $read_conn_max_age        = '60'
  $read_conn_keep_alive     = '45'
  $read_conn_lifetime       = '0'

  $manage_firewall = true
  $java_args       = {}
  $test_url        = '/v3/version'

  $puppetdb_package     = 'puppetdb'
  $puppetdb_service     = 'puppetdb'
  $puppetdb_user        = 'puppetdb'
  $puppetdb_group       = 'puppetdb'
  $confdir              = '/etc/puppetdb/conf.d'
  $puppet_confdir       = '/etc/puppet'
  $masterless           = false
  $terminus_package     = 'puppetdb-terminus'
  $ssl_dir              = '/etc/puppetdb/ssl'

  case $::osfamily {
    'RedHat', 'Suse', 'Archlinux': {
      $puppetdb_initconf    = '/etc/sysconfig/puppetdb'
      $puppet_service_name  = 'puppetmaster'
      $embedded_subname     = 'file:/var/lib/puppetdb/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'
    }
    'Debian': {
      $puppetdb_initconf    = '/etc/default/puppetdb'
      $puppet_service_name  = 'puppetmaster'
      $embedded_subname     = 'file:/var/lib/puppetdb/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'
    }
    'OpenBSD': {
      $puppetdb_initconf    = undef
      $puppet_service_name  = 'puppetmasterd'
      $embedded_subname     = 'file:/var/db/puppetdb/db/db;hsqldb.tx=mvcc;sql.syntax_pgs=true'
    }
    default: {
      fail("${module_name} supports osfamily's RedHat and Debian. Your osfamily is recognized as ${::osfamily}")
    }
  }

  $puppet_conf              = "${puppet_confdir}/puppet.conf"
  $puppetdb_startup_timeout = 120
  $puppetdb_service_status  = 'running'

  $ssl_set_cert_paths        = false
  $ssl_cert_path             = "${ssl_dir}/public.pem"
  $ssl_key_path              = "${ssl_dir}/private.pem"
  $ssl_ca_cert_path          = "${ssl_dir}/ca.pem"
  $ssl_deploy_certs          = false
  $ssl_key                   = undef
  $ssl_cert                  = undef
  $ssl_ca_cert               = undef

}
