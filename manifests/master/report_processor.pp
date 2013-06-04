# Class: puppetdb::master::report_processor
#
# This class configures the puppet master to enable the puppetdb report
# processor
#
# Parameters:
#   ['puppet_conf']  - The puppet config file (defaults to /etc/puppet/puppet.conf)
#
# Actions:
# - Configures the puppet master to use the puppetdb report processor
#
# Requires:
# - Inifile
#
# Sample Usage:
#   class { 'puppetdb::master::report_processor':
#       puppet_conf => '/etc/puppet/puppet.conf',
#       enable => true
#   }
#
#
class puppetdb::master::report_processor(
  $puppet_conf = $puppetdb::params::puppet_conf,
  $enable      = false
) inherits puppetdb::params {

  ini_subsetting { 'puppet.conf/reports/puppetdb':
    ensure               => $enable ? {
      true    => present,
      default => absent
    },
    path                 => $puppet_conf,
    section              => 'master',
    setting              => 'reports',
    subsetting           => 'puppetdb',
    subsetting_separator => ','
  }
}
