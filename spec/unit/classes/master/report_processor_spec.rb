# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::master::report_processor', type: :class do
  around(:each) do |example|
    confdir = RSpec.configuration.confdir
    RSpec.configuration.confdir = '/etc/puppet'
    example.run
    RSpec.configuration.confdir = confdir
  end

  let(:subsetting_params) do
    {
      'path' => '/etc/puppet/puppet.conf',
      'section' => 'master',
      'setting' => 'reports',
      'subsetting' => 'puppetdb',
      'subsetting_separator' => ',',
    }
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
        it { is_expected.to contain_ini_subsetting('puppet.conf/reports/puppetdb').with(subsetting_params.merge('ensure' => 'absent')) }
      end

      describe 'when enabling reports' do
        let(:params) { { 'enable' => true } }

        it { is_expected.to contain_ini_subsetting('puppet.conf/reports/puppetdb').with(subsetting_params.merge('ensure' => 'present')) }
      end
    end
  end
end
