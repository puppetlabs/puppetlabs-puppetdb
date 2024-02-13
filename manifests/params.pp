# @summary default configuration settings
#
# @api private
class puppetdb::params inherits puppetdb::globals {
  $listen_address            = 'localhost'
  $listen_port               = '8080'
  $disable_cleartext         = false
  $open_listen_port          = false
  $ssl_listen_address        = '0.0.0.0'
  $ssl_listen_port           = '8081'
  $ssl_protocols             = undef
  $disable_ssl               = false
  $cipher_suites             = undef
  $open_ssl_listen_port      = undef
  $postgres_listen_addresses = 'localhost'

  $puppetdb_version          = $puppetdb::globals::version
  $manage_dbserver           = true
  $manage_database           = true

  if fact('os.family') =~ /RedHat|Debian/ {
    $manage_pg_repo            = true
  } else {
    $manage_pg_repo            = false
  }

  if $::osfamily =~ /RedHat/ and $facts['os']['release']['major'] == '8' {
    $manage_pg_dnf_module = true
  } else {
    $manage_pg_dnf_module = false
  }

  if $puppetdb_version in ['latest','present'] or versioncmp($puppetdb_version, '7.0.0') >= 0 {
    $postgres_version          = '11'
  } else {
    $postgres_version          = '9.6'
  }

  $puppetdb_major_version = $puppetdb_version ? {
    'latest'  => '8',
    'present' => '8',
    default   => $puppetdb_version.split('.')[0],
  }

  $database_host          = 'localhost'
  $database_port          = '5432'
  $database_name          = 'puppetdb'
  $database_username      = 'puppetdb'
  $database_password      = 'puppetdb'
  $manage_db_password     = true
  $jdbc_ssl_properties    = ''
  $database_validate      = true
  $database_max_pool_size = undef
  $puppetdb_server        = fact('networking.fqdn')

  # These settings manage the various auto-deactivation and auto-purge settings
  $node_ttl               = '7d'
  $node_purge_ttl         = '14d'
  $report_ttl             = '14d'

  $facts_blacklist        = undef

  $gc_interval               = '60'
  $node_purge_gc_batch_limit = '25'

  $log_slow_statements    = '10'
  $conn_max_age           = '60'
  $conn_keep_alive        = '45'
  $conn_lifetime          = '0'

  $max_threads            = undef
  $migrate                = true

  # These settings are for the read database
  $read_database_host                = undef
  $read_database_port                = '5432'
  $read_database_name                = 'puppetdb'
  $read_database_username            = 'puppetdb-read'
  $read_database_password            = 'puppetdb-read'
  $manage_read_db_password           = true
  $read_database_jdbc_ssl_properties = ''
  $read_database_validate            = true
  $read_log_slow_statements          = '10'
  $read_conn_max_age                 = '60'
  $read_conn_keep_alive              = '45'
  $read_conn_lifetime                = '0'
  $read_database_max_pool_size       = undef

  $manage_firewall         = true
  $java_args               = {}
  $merge_default_java_args = true

  $puppetdb_service     = 'puppetdb'
  $masterless           = false

  if !($puppetdb_version in ['latest','present','absent']) and versioncmp($puppetdb_version, '3.0.0') < 0 {
    case fact('os.family') {
      'RedHat', 'Suse', 'Archlinux','Debian': {
        $puppetdb_package       = 'puppetdb'
        $terminus_package       = 'puppetdb-terminus'
        $etcdir                 = '/etc/puppetdb'
        $vardir                 = '/var/lib/puppetdb'
        $puppet_confdir         = pick($puppetdb::globals::puppet_confdir,'/etc/puppet')
        $puppet_service_name    = 'puppetmaster'
      }
      'OpenBSD': {
        $puppetdb_package       = 'puppetdb'
        $terminus_package       = 'puppetdb-terminus'
        $etcdir                 = '/etc/puppetdb'
        $vardir                 = '/var/db/puppetdb'
        $puppet_confdir         = pick($puppetdb::globals::puppet_confdir,'/etc/puppet')
        $puppet_service_name    = 'puppetmasterd'
      }
      'FreeBSD': {
        $puppetdb_package       = inline_epp('puppetdb<%= $puppetdb::params::puppetdb_major_version %>')
        $terminus_package       = inline_epp('puppetdb-terminus<%= $puppetdb::params::puppetdb_major_version %>')
        $etcdir                 = '/usr/local/etc/puppetdb'
        $vardir                 = '/var/db/puppetdb'
        $puppet_confdir         = pick($puppetdb::globals::puppet_confdir,'/usr/local/etc/puppet')
        $puppet_service_name    = 'puppetmaster'
      }
      default: {
        fail("The fact 'os.family' is set to ${fact('os.family')} which is not supported by the puppetdb module.")
      }
    }
    $test_url         = '/v3/version'
  } else {
    case fact('os.family') {
      'RedHat', 'Suse', 'Archlinux','Debian': {
        $puppetdb_package    = 'puppetdb'
        $terminus_package    = 'puppetdb-termini'
        $etcdir              = '/etc/puppetlabs/puppetdb'
        $puppet_confdir      = pick($puppetdb::globals::puppet_confdir,'/etc/puppetlabs/puppet')
        $puppet_service_name = 'puppetserver'
        $vardir              = '/opt/puppetlabs/server/data/puppetdb'
      }
      'OpenBSD': {
        $puppetdb_package    = 'puppetdb'
        $terminus_package    = 'puppetdb-termini'
        $etcdir              = '/etc/puppetlabs/puppetdb'
        $puppet_confdir      = pick($puppetdb::globals::puppet_confdir,'/etc/puppetlabs/puppet')
        $puppet_service_name = undef
        $vardir              = '/opt/puppetlabs/server/data/puppetdb'
      }
      'FreeBSD': {
        $puppetdb_package    = inline_epp('puppetdb<%= $puppetdb::params::puppetdb_major_version %>')
        $terminus_package    = inline_epp('puppetdb-terminus<%= $puppetdb::params::puppetdb_major_version %>')
        $etcdir              = '/usr/local/etc/puppetdb'
        $puppet_confdir      = pick($puppetdb::globals::puppet_confdir,'/usr/local/etc/puppet')
        $puppet_service_name = 'puppetserver'
        $vardir              = '/var/db/puppetdb'
      }
      default: {
        fail("The fact 'os.family' is set to ${fact('os.family')} which is not supported by the puppetdb module.")
      }
    }
    $test_url               = '/pdb/meta/v1/version'
  }

  $confdir = "${etcdir}/conf.d"
  $ssl_dir = "${etcdir}/ssl"

  case fact('os.family') {
    'RedHat', 'Suse', 'Archlinux': {
      $puppetdb_user     = 'puppetdb'
      $puppetdb_group    = 'puppetdb'
      $puppetdb_initconf = '/etc/sysconfig/puppetdb'
    }
    'Debian': {
      $puppetdb_user     = 'puppetdb'
      $puppetdb_group    = 'puppetdb'
      $puppetdb_initconf = '/etc/default/puppetdb'
    }
    'OpenBSD': {
      $puppetdb_user     = '_puppetdb'
      $puppetdb_group    = '_puppetdb'
      $puppetdb_initconf = undef
    }
    'FreeBSD': {
      $puppetdb_user     = 'puppetdb'
      $puppetdb_group    = 'puppetdb'
      $puppetdb_initconf = undef
    }
    default: {
      fail("The fact 'os.family' is set to ${fact('os.family')} which is not supported by the puppetdb module.")
    }
  }

  $puppet_conf              = "${puppet_confdir}/puppet.conf"
  $puppetdb_startup_timeout = 120
  $puppetdb_service_status  = 'running'

  $command_threads          = undef
  $concurrent_writes        = undef
  $store_usage              = undef
  $temp_usage               = undef
  $disable_update_checking  = undef

  # reports of failed actions: https://puppet.com/docs/puppetdb/5.2/maintain_and_tune.html#clean-up-the-dead-letter-office
  $automatic_dlo_cleanup    = true
  # any value for a systemd timer is valid: https://www.freedesktop.org/software/systemd/man/systemd.time.html
  $cleanup_timer_interval   = "*-*-* ${fqdn_rand(24)}:${fqdn_rand(60)}:00"
  $dlo_max_age              = 90

  # certificats used for PostgreSQL SSL configuration. Puppet certificates are used
  $postgresql_ssl_on            = false
  $postgresql_ssl_folder        = "${puppet_confdir}/ssl"
  $postgresql_ssl_cert_path     = "${postgresql_ssl_folder}/certs/${trusted['certname']}.pem"
  $postgresql_ssl_key_path      = "${postgresql_ssl_folder}/private_keys/${trusted['certname']}.pem"
  $postgresql_ssl_ca_cert_path  = "${postgresql_ssl_folder}/certs/ca.pem"

  # certificats used for Jetty configuration
  $ssl_set_cert_paths       = false
  $ssl_cert_path            = "${ssl_dir}/public.pem"
  $ssl_key_path             = "${ssl_dir}/private.pem"
  $ssl_ca_cert_path         = "${ssl_dir}/ca.pem"
  $ssl_deploy_certs         = false
  $ssl_key                  = undef
  $ssl_cert                 = undef
  $ssl_ca_cert              = undef

  # certificate used by PuppetDB SSL Configuration
  $ssl_key_pk8_path         = regsubst($ssl_key_path, '.pem', '.pk8')

  $certificate_whitelist_file = "${etcdir}/certificate-whitelist"
  # the default is free access for now
  $certificate_whitelist      = []
  # change to this to only allow access by the puppet master by default:
  #$certificate_whitelist      = [ $::servername ]

  # Get the parameter name for the database connection pool tuning
  if $puppetdb_version in ['latest','present'] or versioncmp($puppetdb_version, '4.0.0') >= 0 {
    $database_max_pool_size_setting_name = 'maximum-pool-size'
  } elsif versioncmp($puppetdb_version, '2.8.0') >= 0 {
    $database_max_pool_size_setting_name = 'partition-conn-max'
  } else {
    $database_max_pool_size_setting_name = undef
  }

  # java binary path for PuppetDB. If undef, default will be used.
  $java_bin = undef
}
