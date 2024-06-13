# @summary manage the puppetdb.conf file on the puppet primary
#
# @api private
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
  Ini_setting {
    ensure  => present,
    section => 'main',
    path    => "${puppet_confdir}/puppetdb.conf",
  }

  if $legacy_terminus {
    $legacy_ensure = 'present'
    $newterminus_ensure = 'absent'
  } else {
    $legacy_ensure = 'absent'
    $newterminus_ensure = 'present'
  }

  ini_setting { 'puppetdbserver':
    ensure  => $legacy_ensure,
    setting => 'server',
    value   => $server,
  }

  ini_setting { 'puppetdbport':
    ensure  => $legacy_ensure,
    setting => 'port',
    value   => $port,
  }

  ini_setting { 'puppetdbserver_urls':
    ensure  => $newterminus_ensure,
    setting => 'server_urls',
    value   => "https://${server}:${port}/",
  }

  ini_setting { 'soft_write_failure':
    setting => 'soft_write_failure',
    value   => $soft_write_failure,
  }
}
