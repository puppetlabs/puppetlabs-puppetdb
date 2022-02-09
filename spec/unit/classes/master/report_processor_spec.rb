require 'spec_helper'

describe 'puppetdb::master::report_processor', type: :class do
  around(:each) do |example|
    confdir = RSpec.configuration.confdir
    RSpec.configuration.confdir = '/etc/puppet'
    example.run
    RSpec.configuration.confdir = confdir
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(puppetversion: Puppet.version,
                    service_provider: 'systemd',
                    clientcert: 'test.domain.local')
      end

      it { is_expected.to contain_class('puppetdb::master::report_processor') }

      describe 'when using default values' do
        it {
          is_expected.to contain_ini_subsetting('puppet.conf/reports/puppetdb')
            .with(
              'ensure'                => 'absent',
              'path'                  => '/etc/puppet/puppet.conf',
              'section'               => 'master',
              'setting'               => 'reports',
              'subsetting'            => 'puppetdb',
              'subsetting_separator'  => ',',
            )
        }
      end

      describe 'when enabling reports' do
        let(:params) do
          {
            'enable' => true,
          }
        end

        it {
          is_expected.to contain_ini_subsetting('puppet.conf/reports/puppetdb')
            .with(
              'ensure'                => 'present',
              'path'                  => '/etc/puppet/puppet.conf',
              'section'               => 'master',
              'setting'               => 'reports',
              'subsetting'            => 'puppetdb',
              'subsetting_separator'  => ',',
            )
        }
      end
    end
  end
end
