# @summary manage the puppetdb.conf file on the puppet primary
#
# @api private
class puppetdb::master::puppetdb_conf (
  Stdlib::Host                                               $server             = 'localhost',
  Variant[Stdlib::Port::Unprivileged, Pattern[/\A[0-9]+\Z/]] $port               = '8081',
  Boolean                                                    $soft_write_failure = $puppetdb::disable_ssl ? {
    true => true,
    default => false,
  },
  Stdlib::Absolutepath                                       $puppet_confdir     = $puppetdb::params::puppet_confdir,
  Boolean                                                    $legacy_terminus    = $puppetdb::params::terminus_package ? {
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
    ini_setting { 'puppetdbserver':
      setting => 'server',
      value   => $server,
    }
    ini_setting { 'puppetdbport':
      setting => 'port',
      value   => $port,
    }
  } else {
    ini_setting { 'puppetdbserver_urls':
      setting => 'server_urls',
      value   => "https://${server}:${port}/",
    }
  }

  ini_setting { 'soft_write_failure':
    setting => 'soft_write_failure',
    value   => $soft_write_failure,
  }
}
