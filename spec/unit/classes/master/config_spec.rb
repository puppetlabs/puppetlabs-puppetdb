require 'spec_helper'

describe 'puppetdb::master::config', :type => :class do

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

  context 'when PuppetDB on remote server' do

    context 'when using default values' do
      it { should compile.with_all_deps }
    end

  end

  context 'when PuppetDB and Puppet Master are on the same server' do

    context 'when using default values' do
      let(:pre_condition) { 'class { "puppetdb": }' }

      it { should contain_puppetdb_conn_validator('puppetdb_conn').with(
                    :puppetdb_server => 'puppetdb.example.com',
                    :puppetdb_port => '8081',
                    :use_ssl => 'true') }
    end

    context 'when puppetdb class is declared with disable_ssl => true' do
      let(:pre_condition) { 'class { "puppetdb": disable_ssl => true }' }

      it { should contain_puppetdb_conn_validator('puppetdb_conn').with(
                    :puppetdb_port => '8080',
                    :use_ssl => 'false')}
    end

    context 'when puppetdb_port => 1234' do
      let(:pre_condition) { 'class { "puppetdb": }' }
      let(:params) do { :puppetdb_port => '1234' } end

      it { should contain_puppetdb_conn_validator('puppetdb_conn').with(
                    :puppetdb_port => '1234',
                    :use_ssl => 'true')}
    end

    context 'when puppetdb_port => 1234 AND the puppetdb class is declared with disable_ssl => true' do
      let(:pre_condition) { 'class { "puppetdb": disable_ssl => true }' }
      let(:params) do {:puppetdb_port => '1234'} end

      it { should contain_puppetdb_conn_validator('puppetdb_conn').with(
                    :puppetdb_port => '1234',
                    :use_ssl => 'false')}

    end
    
    context 'when using default values' do
      it { should contain_package('puppetdb-termini').with( :ensure => 'present' )}
      it { should contain_puppetdb_conn_validator('puppetdb_conn').with(:test_url => '/pdb/meta/v1/version')}
    end
    
    context 'when using an older puppetdb version' do
      let (:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }
      it { should contain_package('puppetdb-terminus').with( :ensure => '2.2.0' )}
      it { should contain_puppetdb_conn_validator('puppetdb_conn').with(:test_url => '/v3/version')}
    end

  end

end
