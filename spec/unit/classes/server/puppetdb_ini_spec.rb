require 'spec_helper'

describe 'puppetdb::server::puppetdb', :type => :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        :osfamily                 => 'RedHat',
        :fqdn                     => 'test.domain.local',
      }
    end

    it { should contain_class('puppetdb::server::puppetdb') }

    describe 'when using default values' do
      it { should contain_ini_setting('puppetdb-connections-from-master-only').
        with(
             'ensure'  => 'absent',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/puppetdb.ini',
             'section' => 'puppetdb',
             'setting' => 'certificate-whitelist',
             'value'   => '/etc/puppetlabs/puppetdb/certificate-whitelist'
             )}
      it { should contain_file('/etc/puppetlabs/puppetdb/certificate-whitelist').
        with(
             'ensure'  => 'absent',
             'owner'   => 0,
             'group'   => 0,
             'mode'    => '0644',
             'content' => ''
             )}
    end

    describe 'when restricting access to puppetdb' do
      let(:params) do
        {
          'certificate_whitelist' => [ 'puppetmaster' ]
        }
      end
      it { should contain_ini_setting('puppetdb-connections-from-master-only').
        with(
             'ensure'  => 'present',
             'path'    => '/etc/puppetlabs/puppetdb/conf.d/puppetdb.ini',
             'section' => 'puppetdb',
             'setting' => 'certificate-whitelist',
             'value'   => '/etc/puppetlabs/puppetdb/certificate-whitelist'
             )}
      it { should contain_file('/etc/puppetlabs/puppetdb/certificate-whitelist').
        with(
             'ensure'  => 'present',
             'owner'   => 0,
             'group'   => 0,
             'mode'    => '0644',
             'content' => "puppetmaster\n"
             )}
    end
  end
end
