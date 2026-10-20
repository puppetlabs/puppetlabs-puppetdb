# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::server::command_processing', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }
  let(:pre_condition) { 'include puppetdb::server::global' }
  let(:config_ini) { '/etc/puppetlabs/puppetdb/conf.d/config.ini' }

  it { is_expected.to contain_class('puppetdb::server::command_processing') }

  describe 'when using default values' do
    it { is_expected.to contain_ini_setting('puppetdb_command_processing_threads').with('ensure' => 'absent', 'path' => config_ini, 'section' => 'command-processing', 'setting' => 'threads') }

    it do
      expect(catalogue).to contain_ini_setting('puppetdb_command_processing_concurrent_writes')
        .with('ensure' => 'absent', 'path' => config_ini, 'section' => 'command-processing', 'setting' => 'concurrent-writes')
    end

    it { is_expected.to contain_ini_setting('puppetdb_command_processing_store_usage').with('ensure' => 'absent', 'path' => config_ini, 'section' => 'command-processing', 'setting' => 'store-usage') }
    it { is_expected.to contain_ini_setting('puppetdb_command_processing_temp_usage').with('ensure' => 'absent', 'path' => config_ini, 'section' => 'command-processing', 'setting' => 'temp-usage') }
  end

  describe 'when using legacy PuppetDB' do
    let(:pre_condition) do
      [
        'class { "puppetdb::globals": version => "2.2.0", }',
        super(),
      ].join("\n")
    end
    let(:legacy_ini) { '/etc/puppetdb/conf.d/config.ini' }

    it { is_expected.to contain_ini_setting('puppetdb_command_processing_threads').with('ensure' => 'absent', 'path' => legacy_ini, 'section' => 'command-processing', 'setting' => 'threads') }
    it { is_expected.to contain_ini_setting('puppetdb_command_processing_store_usage').with('ensure' => 'absent', 'path' => legacy_ini, 'section' => 'command-processing', 'setting' => 'store-usage') }
    it { is_expected.to contain_ini_setting('puppetdb_command_processing_temp_usage').with('ensure' => 'absent', 'path' => legacy_ini, 'section' => 'command-processing', 'setting' => 'temp-usage') }
  end

  describe 'when using custom values' do
    let(:params) { { 'command_threads' => 10, 'concurrent_writes' => 3, 'store_usage' => 4000, 'temp_usage' => 2000 } }

    it do
      expect(catalogue).to contain_ini_setting('puppetdb_command_processing_threads')
        .with('ensure' => 'present', 'path' => config_ini, 'section' => 'command-processing', 'setting' => 'threads', 'value' => '10')
    end

    it do
      expect(catalogue).to contain_ini_setting('puppetdb_command_processing_concurrent_writes')
        .with('ensure' => 'present', 'path' => config_ini, 'section' => 'command-processing', 'setting' => 'concurrent-writes', 'value' => '3')
    end

    it do
      expect(catalogue).to contain_ini_setting('puppetdb_command_processing_store_usage')
        .with('ensure' => 'present', 'path' => config_ini, 'section' => 'command-processing', 'setting' => 'store-usage', 'value' => '4000')
    end

    it do
      expect(catalogue).to contain_ini_setting('puppetdb_command_processing_temp_usage')
        .with('ensure' => 'present', 'path' => config_ini, 'section' => 'command-processing', 'setting' => 'temp-usage', 'value' => '2000')
    end
  end
end
