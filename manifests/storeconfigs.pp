# Class: puppetdb::storeconfigs
#
# This class installs and configures the puppetdb terminus pacakge
#
# Parameters:
#   ['puppet_confdir']    - The config directory of puppet
#   ['dbport']            - The port of the puppetdb
#   ['dbserver']          - The dns name of the puppetdb server
#   ['puppet_conf']       - The puppet config file
#
# Actions:
# - Configures the puppet to use stored configs
#
# Requires:
# - Inifile
# - Class['puppetdb::storeconfigs']
#
# Sample Usage:
#   class { 'puppetdb::storeconfigs':
#       dbserver                   => 'localhost'
#       dbport                     => 8081,
#   }
#
class puppetdb::storeconfigs(
    $dbserver = 'localhost',
    $dbport = '8081',
    $puppet_confdir = '/etc/puppet/',
    $puppet_conf = '/etc/puppet/puppet.conf',
)
{
  class{ 'puppetdb::dbterminus':
    puppet_confdir => $puppet_confdir,
    dbport         => $dbport,
    dbserver       => $dbserver,
  }

  Ini_setting{
    section => 'master',
    path    => $puppet_conf,
    require => Class[puppetdb::dbterminus],
  }

  ini_setting {'puppetmasterstoreconfigserver':
    ensure  => present,
    setting => 'server',
    value   => $dbserver,
  }

  ini_setting {'puppetmasterstoreconfig':
    ensure  => present,
    setting => 'storeconfigs',
    value   => true,
  }

  ini_setting {'puppetmasterstorebackend':
    ensure  => present,
    setting => 'storeconfigs_backend',
    value   => 'puppetdb',
  }
}
