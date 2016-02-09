# PRIVATE CLASS - do not use directly
#
# The puppetdb default configuration settings.
class puppetdb::params inherits puppetdb::globals {
  $listen_address            = 'localhost'
  $listen_port               = '8080'
  $disable_cleartext         = false
  $open_listen_port          = false
  $ssl_listen_address        = '0.0.0.0'
  $ssl_listen_port           = '8081'
  $ssl_protocols             = undef
  $disable_ssl               = false
  $open_ssl_listen_port      = undef
  $postgres_listen_addresses = 'localhost'

  $puppetdb_version          = $puppetdb::globals::version
  $database                  = $puppetdb::globals::database
  $manage_dbserver           = true
  $manage_pg_repo            = true
  $postgres_version          = '9.4'

  # The remaining database settings are not used for an embedded database
  $database_host       = 'localhost'
  $database_port       = '5432'
  $database_name       = 'puppetdb'
  $database_username   = 'puppetdb'
  $database_password   = 'puppetdb'
  $database_ssl        = undef
  $jdbc_ssl_properties = ''
  $database_validate   = true

  # These settings manage the various auto-deactivation and auto-purge settings
  $node_ttl               = '0s'
  $node_purge_ttl         = '0s'
  $report_ttl             = '14d'

  $gc_interval            = '60'

  $log_slow_statements    = '10'
  $conn_max_age           = '60'
  $conn_keep_alive        = '45'
  $conn_lifetime          = '0'

  $max_threads            = undef

  # These settings are for the read database
  $read_database                     = 'postgres'
  $read_database_host                = undef
  $read_database_port                = '5432'
  $read_database_name                = 'puppetdb'
  $read_database_username            = 'puppetdb'
  $read_database_password            = 'puppetdb'
  $read_database_ssl                 = undef
  $read_database_jdbc_ssl_properties = ''
  $read_database_validate            = true
  $read_log_slow_statements          = '10'
  $read_conn_max_age                 = '60'
  $read_conn_keep_alive              = '45'
  $read_conn_lifetime                = '0'

  $manage_firewall         = true
  $java_args               = {}
  $merge_default_java_args = true

  $puppetdb_package     = 'puppetdb'
  $puppetdb_service     = 'puppetdb'
  $puppetdb_user        = 'puppetdb'
  $puppetdb_group       = 'puppetdb'
  $masterless           = false

  if !($puppetdb_version in ['latest','present','absent']) and versioncmp($puppetdb_version, '3.0.0') < 0 {
    case $::osfamily {
      'RedHat', 'Suse', 'Archlinux','Debian': {
        $etcdir                 = '/etc/puppetdb'
        $vardir                 = '/var/lib/puppetdb'
        $database_embedded_path = "${vardir}/db/db"
        $puppet_confdir         = pick($settings::confdir,'/etc/puppet')
        $puppet_service_name    = 'puppetmaster'
      }
      'OpenBSD': {
        $etcdir                 = '/etc/puppetdb'
        $vardir                 = '/var/db/puppetdb'
        $database_embedded_path = "${vardir}/db/db"
        $puppet_confdir         = pick($settings::confdir,'/etc/puppet')
        $puppet_service_name    = 'puppetmasterd'
      }
      'FreeBSD': {
        $etcdir                 = '/usr/local/etc/puppetdb'
        $vardir                 = '/var/db/puppetdb'
        $database_embedded_path = "${vardir}/db/db"
        $puppet_confdir         = pick($settings::confdir,'/usr/local/etc/puppet')
        $puppet_service_name    = 'puppetmaster'
      }
      default: {
        fail("The fact 'osfamily' is set to ${::osfamily} which is not supported by the puppetdb module.")
      }
    }
    $terminus_package = 'puppetdb-terminus'
    $test_url         = '/v3/version'
  } else {
    case $::osfamily {
      'RedHat', 'Suse', 'Archlinux','Debian': {
        $etcdir              = '/etc/puppetlabs/puppetdb'
        $puppet_confdir      = pick($settings::confdir,'/etc/puppetlabs/puppet')
        $puppet_service_name = 'puppetserver'
      }
      'OpenBSD': {
        $etcdir              = '/etc/puppetlabs/puppetdb'
        $puppet_confdir      = pick($settings::confdir,'/etc/puppetlabs/puppet')
        $puppet_service_name = undef
      }
      'FreeBSD': {
        $etcdir              = '/usr/local/etc/puppetlabs/puppetdb'
        $puppet_confdir      = pick($settings::confdir,'/usr/local/etc/puppetlabs/puppet')
        $puppet_service_name = undef
      }
      default: {
        fail("The fact 'osfamily' is set to ${::osfamily} which is not supported by the puppetdb module.")
      }
    }
    $terminus_package       = 'puppetdb-termini'
    $test_url               = '/pdb/meta/v1/version'
    $vardir                 = '/opt/puppetlabs/server/data/puppetdb'
    $database_embedded_path = "${vardir}/db/db"
  }

  $confdir = "${etcdir}/conf.d"
  $ssl_dir = "${etcdir}/ssl"

  case $::osfamily {
    'RedHat', 'Suse', 'Archlinux': {
      $puppetdb_initconf = '/etc/sysconfig/puppetdb'
    }
    'Debian': {
      $puppetdb_initconf = '/etc/default/puppetdb'
    }
    'OpenBSD','FreeBSD': {
      $puppetdb_initconf = undef
    }
    default: {
      fail("The fact 'osfamily' is set to ${::osfamily} which is not supported by the puppetdb module.")
    }
  }

  $puppet_conf              = "${puppet_confdir}/puppet.conf"
  $puppetdb_startup_timeout = 120
  $puppetdb_service_status  = 'running'

  $command_threads          = undef
  $store_usage              = undef
  $temp_usage               = undef

  $ssl_set_cert_paths       = false
  $ssl_cert_path            = "${ssl_dir}/public.pem"
  $ssl_key_path             = "${ssl_dir}/private.pem"
  $ssl_ca_cert_path         = "${ssl_dir}/ca.pem"
  $ssl_deploy_certs         = false
  $ssl_key                  = undef
  $ssl_cert                 = undef
  $ssl_ca_cert              = undef

  $certificate_whitelist_file = "${etcdir}/certificate-whitelist"
  # the default is free access for now
  $certificate_whitelist      = [ ]
  # change to this to only allow access by the puppet master by default:
  #$certificate_whitelist      = [ $::servername ]
}
