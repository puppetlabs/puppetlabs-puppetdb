# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::master::config', type: :class do
  let(:node) { 'puppetdb.example.com' }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'when PuppetDB is on a remote server' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('puppetdb-termini').with(ensure: 'present') }
        it { is_expected.to contain_puppetdb_conn_validator('puppetdb_conn').with(test_url: '/pdb/meta/v1/version') }
      end

      context 'when PuppetDB and Puppet Master are on the same server using default values' do
        let(:pre_condition) { 'class { "puppetdb": }' }

        it {
          expect(catalogue).to contain_puppetdb_conn_validator('puppetdb_conn').with(
            puppetdb_server: 'puppetdb.example.com',
            puppetdb_port: '8081',
            use_ssl: 'true',
          )
        }
      end

      context 'when puppetdb class is declared with disable_ssl => true' do
        let(:pre_condition) { 'class { "puppetdb": disable_ssl => true }' }

        it {
          expect(catalogue).to contain_puppetdb_conn_validator('puppetdb_conn').with(
            puppetdb_port: '8080',
            use_ssl: 'false',
          )
        }
      end

      context 'when puppetdb_port => 1234' do
        let(:pre_condition) { 'class { "puppetdb": }' }
        let(:params) { { puppetdb_port: '1234' } }

        it {
          expect(catalogue).to contain_puppetdb_conn_validator('puppetdb_conn').with(
            puppetdb_port: '1234',
            use_ssl: 'true',
          )
        }
      end

      context 'when puppetdb_port => 1234 AND the puppetdb class is declared with disable_ssl => true' do
        let(:pre_condition) { 'class { "puppetdb": disable_ssl => true }' }
        let(:params) { { puppetdb_port: '1234' } }

        it {
          expect(catalogue).to contain_puppetdb_conn_validator('puppetdb_conn').with(
            puppetdb_port: '1234',
            use_ssl: 'false',
          )
        }
      end

      context 'when using an older puppetdb version' do
        let(:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }

        it { is_expected.to contain_package('puppetdb-terminus').with(ensure: '2.2.0') }
        it { is_expected.to contain_puppetdb_conn_validator('puppetdb_conn').with(test_url: '/v3/version') }

        it {
          expect(catalogue).to contain_service('puppetmaster')
            .with_ensure('running')
            .with_enable(true)
        }
      end

      context 'when restart_puppet is true with create_puppet_service_resource as default' do
        let(:pre_condition) { 'class { "puppetdb": }' }
        let(:params) do
          {
            puppet_service_name: 'puppetserver',
            restart_puppet: true,
          }
        end

        it { is_expected.to contain_service('puppetserver').with(ensure: 'running') }
      end

      context 'when restart_puppet is true with create_puppet_service_resource = true' do
        let(:pre_condition) { 'class { "puppetdb": }' }
        let(:params) do
          {
            create_puppet_service_resource: true,
            puppet_service_name: 'puppetserver',
            restart_puppet: true,
          }
        end

        it { is_expected.to contain_service('puppetserver').with(ensure: 'running') }
      end

      context 'when restart_puppet is true with create_puppet_service_resource = false' do
        let(:pre_condition) { 'class { "puppetdb": }' }
        # Also setting the various parameters that notify the service to be false. Otherwise this error surfaces:
        # `Could not find resource 'Service[puppetserver]' for relationship from 'Class[Puppetdb::Master::Puppetdb_conf]'`
        let(:params) do
          {
            create_puppet_service_resource: false,
            manage_config: false,
            manage_report_processor: false,
            manage_routes: false,
            puppet_service_name: 'puppetserver',
            restart_puppet: true,
          }
        end

        it { is_expected.not_to contain_service('puppetserver') }
      end

      context 'when upgrading to from v2 to v3 of PuppetDB on RedHat', if: os =~ %r{^redhat-7} do
        let(:pre_condition) { 'class { "puppetdb::globals": version => "3.1.1-1.el7", }' }

        it { is_expected.to contain_exec('Remove puppetdb-terminus metadata for upgrade').with(command: 'rpm -e --justdb puppetdb-terminus') }
      end
    end
  end
end
