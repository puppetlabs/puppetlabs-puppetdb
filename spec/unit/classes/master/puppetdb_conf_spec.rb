require 'spec_helper'

describe 'puppetdb::master::puppetdb_conf', :type => :class do

  let(:facts) do
    {
      :fqdn => 'puppetdb.example.com',
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :operatingsystemrelease => '6.0',
      :kernel => 'Linux',
      :concat_basedir => '/var/lib/puppet/concat',
      :id => 'root',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    }
  end
  
  let(:pre_condition) { 'class { "puppetdb": }' }
  
  context 'when using using default values' do
    it { should contain_ini_setting('puppetdbserver_urls').with( :value => 'https://localhost:8081/' )}
  end
  
  context 'when using using default values' do
    let (:params) do { :legacy_terminus => true, } end
    it { should contain_ini_setting('puppetdbserver').with( :value => 'localhost' )}
    it { should contain_ini_setting('puppetdbport').with( :value => '8081' )}
  end
  
end
