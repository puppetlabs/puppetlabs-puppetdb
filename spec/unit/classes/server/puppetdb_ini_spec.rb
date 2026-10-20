# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::server::puppetdb', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }
  let(:ini_path) { '/etc/puppetlabs/puppetdb/conf.d/puppetdb.ini' }
  let(:whitelist) { '/etc/puppetlabs/puppetdb/certificate-whitelist' }

  it { is_expected.to contain_class('puppetdb::server::puppetdb') }

  describe 'when using default values' do
    it do
      expect(catalogue).to contain_ini_setting('puppetdb-connections-from-master-only')
        .with('ensure' => 'absent', 'path' => ini_path, 'section' => 'puppetdb', 'setting' => 'certificate-whitelist', 'value' => whitelist)
    end

    it { is_expected.to contain_file(whitelist).with('ensure' => 'absent', 'owner' => 0, 'group' => 0, 'mode' => '0644', 'content' => '') }

    it { is_expected.to contain_file(ini_path).with('ensure' => 'file', 'owner' => 'root', 'group' => 'puppetdb', 'mode' => '0640') }

    it { is_expected.to contain_ini_setting('puppetdb_disable_update_checking').with('ensure' => 'absent', 'path' => ini_path, 'section' => 'puppetdb', 'setting' => 'disable-update-checking') }
  end

  describe 'when restricting access to puppetdb' do
    let(:params) do
      {
        'certificate_whitelist' => ['puppetmaster'],
      }
    end

    it do
      expect(catalogue).to contain_ini_setting('puppetdb-connections-from-master-only')
        .with('ensure' => 'present', 'path' => ini_path, 'section' => 'puppetdb', 'setting' => 'certificate-whitelist', 'value' => whitelist)
    end

    it { is_expected.to contain_file(whitelist).with('ensure' => 'present', 'owner' => 0, 'group' => 0, 'mode' => '0644', 'content' => "puppetmaster\n") }
  end

  describe 'when enable disable-update-checking' do
    let(:params) do
      {
        'disable_update_checking' => true,
      }
    end

    it do
      expect(catalogue).to contain_ini_setting('puppetdb_disable_update_checking')
        .with('ensure' => 'present', 'path' => ini_path, 'section' => 'puppetdb', 'setting' => 'disable-update-checking', 'value' => 'true')
    end
  end
end
