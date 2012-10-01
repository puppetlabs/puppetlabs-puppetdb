node pe_puppetmaster_server {
  class { 'puppetdb::master::config':
    puppetdb_server     => 'puppetdb.example.com',
    puppet_confdir      => '/etc/puppetlabs/puppet',
    terminus_package    => 'pe-puppetdb-terminus',
    puppet_service_name => 'pe-httpd',
  }
}

node pe_puppetdb_server {
  class { 'puppetdb':
    puppetdb_package => 'pe-puppetdb',
    puppetdb_service => 'pe-puppetdb',
    confdir          => '/etc/puppetlabs/puppetdb/conf.d',
  }
}
