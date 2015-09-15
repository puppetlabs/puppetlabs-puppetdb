require 'spec_helper'

describe 'puppetdb::server::command_processing', :type => :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        :osfamily                 => 'OpenBSD',
      }
    end

    it { should contain_class('puppetdb::server::command_processing') }

    describe 'when using default values' do
      it { should contain_ini_setting('puppetdb_command_processing_threads').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'threads'
             )}
      it { should contain_ini_setting('puppetdb_command_processing_store_usage').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'store-usage'
             )}
      it { should contain_ini_setting('puppetdb_command_processing_temp_usage').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'temp-usage'
             )}
    end

    describe 'when using legacy PuppetDB' do
      let (:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }
      it { should contain_ini_setting('puppetdb_command_processing_threads').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'threads'
             )}
      it { should contain_ini_setting('puppetdb_command_processing_store_usage').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'store-usage'
             )}
      it { should contain_ini_setting('puppetdb_command_processing_temp_usage').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'temp-usage'
             )}
    end

    describe 'when using custom values' do
      let(:params) do
        {
          'command_threads' => 10,
          'store_usage'     => 4000,
          'temp_usage'      => 2000,
        }
      end
      it { should contain_ini_setting('puppetdb_command_processing_threads').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'threads',
             'value'   => '10'
             )}
      it { should contain_ini_setting('puppetdb_command_processing_store_usage').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'store-usage',
             'value'   => '4000'
             )}
      it { should contain_ini_setting('puppetdb_command_processing_temp_usage').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/config.ini',
             'section' => 'command-processing',
             'setting' => 'temp-usage',
             'value'   => '2000'
             )}
    end
  end
end
