# Manage the puppetdb.conf file on the puppeet master. See README.md for more
# details.
class puppetdb::master::puppetdb_conf (
  $server             = 'localhost',
  $port               = '8081',
  $soft_write_failure = $puppetdb::disable_ssl ? {
    true => true,
    default => false,
  },
  $puppet_confdir     = $puppetdb::params::puppet_confdir,
  $legacy_terminus    = $puppetdb::params::terminus_package ? {
    /(puppetdb-terminus)/ => true,
    default               => false,
  },
  ) inherits puppetdb::params {

  $ini_setting_defaults = {
    ensure  => present,
    section => 'main',
    path    => "${puppet_confdir}/puppetdb.conf",
  }

  if $legacy_terminus {
    ini_setting { 'puppetdbserver':
      setting => 'server',
      value   => $server,
      *       => $ini_setting_defaults,
    }
    ini_setting { 'puppetdbport':
      setting => 'port',
      value   => $port,
      *       => $ini_setting_defaults,
    }
  } else {
    ini_setting { 'puppetdbserver_urls':
      setting => 'server_urls',
      value   => "https://${server}:${port}/",
      *       => $ini_setting_defaults,
    }
  }

  ini_setting { 'soft_write_failure':
    setting => 'soft_write_failure',
    value   => $soft_write_failure,
    *       => $ini_setting_defaults,
  }
}
