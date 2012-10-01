# This manifest shows an example of how you might set up puppetdb to work with
# Puppet Enterprise, as opposed to puppet open source.

class pe_puppetdb {
  class { 'puppetdb':
    puppetdb_package => 'pe-puppetdb',
    puppetdb_service => 'pe-puppetdb',
    confdir          => '/etc/puppetlabs/puppetdb/conf.d',
  }
}
