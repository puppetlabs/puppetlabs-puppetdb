require 'spec_helper'

describe 'puppetdb::server::jetty', :type => :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        :osfamily                 => 'RedHat',
        :fqdn                     => 'test.domain.local',
      }
    end

    it { should contain_class('puppetdb::server::jetty') }

    describe 'when using default values' do
      it { should contain_ini_setting('puppetdb_host').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'host',
             'value'   => 'localhost'
             )}
      it { should contain_ini_setting('puppetdb_port').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'port',
             'value'   => 8080
             )}
      it { should contain_ini_setting('puppetdb_sslhost').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'ssl-host',
             'value'   => '0.0.0.0'
             )}
      it { should contain_ini_setting('puppetdb_sslport').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'ssl-port',
             'value'   => 8081
             )}
      it { should_not contain_ini_setting('puppetdb_sslprotocols') }
    end

    describe 'when using a legacy PuppetDB version' do
      let (:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }
      it { should contain_ini_setting('puppetdb_host').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'host',
             'value'   => 'localhost'
             )}
      it { should contain_ini_setting('puppetdb_port').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'port',
             'value'   => 8080
             )}
      it { should contain_ini_setting('puppetdb_sslhost').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'ssl-host',
             'value'   => '0.0.0.0'
             )}
      it { should contain_ini_setting('puppetdb_sslport').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'ssl-port',
             'value'   => 8081
             )}
      it { should_not contain_ini_setting('puppetdb_sslprotocols') }
    end

    describe 'when disabling ssl' do
      let(:params) do
        {
          'disable_ssl' => true
        }
      end
      it { should contain_ini_setting('puppetdb_host').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'host',
             'value'   => 'localhost'
             )}
      it { should contain_ini_setting('puppetdb_port').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'port',
             'value'   => 8080
             )}
      it { should contain_ini_setting('puppetdb_sslhost').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'ssl-host'
             )}
      it { should contain_ini_setting('puppetdb_sslport').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'ssl-port'
             )}
    end

    describe 'when setting max_threads' do
      let(:params) do
        {
          'max_threads' => 150
        }
      end
      it { should contain_ini_setting('puppetdb_max_threads').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
             'section' => 'jetty',
             'setting' => 'max-threads',
             'value'   => '150'
             )}
    end

    describe 'when setting ssl_protocols' do
      context 'to a valid string' do
        let(:params) { { 'ssl_protocols' => 'TLSv1, TLSv1.1, TLSv1.2' } }

        it {
          should contain_ini_setting('puppetdb_sslprotocols').with(
            'ensure' => 'present',
            'path' => '/etc/puppetlabs/puppetdb/conf.d/jetty.ini',
            'section' => 'jetty',
            'setting' => 'ssl-protocols',
            'value' => 'TLSv1, TLSv1.1, TLSv1.2'
          )
        }
      end

      context 'to an invalid type (non-string)' do
        let(:params) { { 'ssl_protocols' => ['invalid','type'] } }

        it 'should fail' do
          expect {
            should contain_class('puppetdb::server::jetty')
          }.to raise_error(Puppet::Error)
        end
      end
    end
  end
end
