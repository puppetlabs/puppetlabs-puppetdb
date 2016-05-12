# PRIVATE CLASS - do not use directly
class puppetdb::server::puppetdb (
  $certificate_whitelist_file = $puppetdb::params::certificate_whitelist_file,
  $certificate_whitelist      = $puppetdb::params::certificate_whitelist,
  $confdir                    = $puppetdb::params::confdir,
  $puppetdb_user              = $puppetdb::params::puppetdb_user,
  $puppetdb_group             = $puppetdb::params::puppetdb_group,
) inherits puppetdb::params {

  file { "${confdir}/puppetdb.ini":
    ensure => file,
    owner => $puppetdb_user,
    group => $puppetdb_group,
    mode => '0600',
  }

  # Set the defaults
  Ini_setting {
    path    => "${confdir}/puppetdb.ini",
    ensure  => present,
    section => 'puppetdb',
    require => File["${confdir}/puppetdb.ini"],
  }

  $certificate_whitelist_setting_ensure = empty($certificate_whitelist) ? {
    true    => 'absent',
    default => 'present',
  }

  # accept connections only from puppet master
  ini_setting {'puppetdb-connections-from-master-only':
    ensure  => $certificate_whitelist_setting_ensure,
    path    => "${confdir}/puppetdb.ini",
    section => 'puppetdb',
    setting => 'certificate-whitelist',
    value   => $certificate_whitelist_file,
  }

  file { $certificate_whitelist_file:
    ensure  => $certificate_whitelist_setting_ensure,
    content => template('puppetdb/certificate-whitelist.erb'),
    mode    => '0644',
    owner   => 0,
    group   => 0,
  }
}
