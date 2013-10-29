require 'spec_helper'

describe 'puppetdb::master::config', :type => :class do
  context 'on a supported platform' do
    let(:facts) do
      {
          :osfamily               => 'RedHat',
          :fqdn                   => 'test.domain.local',
          :puppetversion          => '3.3.1',
      }
    end

    describe 'when validating the puppetdb connection' do
      context 'with validate using ssl' do
        let(:params) do
          {
            'validate_using_ssl' => true,
          }
        end

        it { should contain_puppetdb_conn_validator('puppetdb_conn').with(
          'puppetdb_server'      => 'test.domain.local',
          'puppetdb_port'        => 8081,
          'use_ssl'              => true,
          'timeout'              => 120,
          'require'              => 'Package[puppetdb-terminus]'
        )}
      end

      context 'without validate using ssl' do
        let(:params) do
          {
            'validate_using_ssl' => false,
          }
        end

        it { should contain_puppetdb_conn_validator('puppetdb_conn').with(
          'puppetdb_server'      => 'test.domain.local',
          'puppetdb_port'        => 8081,
          'use_ssl'              => false,
          'timeout'              => 120,
          'require'              => 'Package[puppetdb-terminus]'
        )}
      end
    end
  end
end
