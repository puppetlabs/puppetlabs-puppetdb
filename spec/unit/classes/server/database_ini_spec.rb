# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::server::database', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }
  let(:default_ini) { '/etc/puppetlabs/puppetdb/conf.d/database.ini' }

  it { is_expected.to contain_class('puppetdb::server::database') }

  ['default', 'legacy'].each do |values|
    describe "when using #{values} values" do
      let(:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' } if values == 'legacy'
      let(:pdbconfdir) do
        if values == 'legacy'
          '/etc/puppetdb/conf.d'
        else
          '/etc/puppetlabs/puppetdb/conf.d'
        end
      end
      let(:ini) { "#{pdbconfdir}/database.ini" }

      it { is_expected.to contain_file(ini).with('ensure' => 'file', 'owner' => 'root', 'group' => 'puppetdb', 'mode' => '0640') }
      it { is_expected.to contain_ini_setting('puppetdb_psdatabase_username').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'username', 'value' => 'puppetdb') }

      it do
        expect(catalogue).to contain_ini_setting('puppetdb_psdatabase_password')
          .with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'password', 'value' => 'puppetdb', 'show_diff' => false)
      end

      it { is_expected.to contain_ini_setting('puppetdb_pgs').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'syntax_pgs', 'value' => true) }
      it { is_expected.to contain_ini_setting('puppetdb_subname').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'subname', 'value' => '//localhost:5432/puppetdb') }
      it { is_expected.to contain_ini_setting('puppetdb_gc_interval').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'gc-interval', 'value' => '60') }

      it do
        expect(catalogue).to contain_ini_setting('puppetdb_node_purge_gc_batch_limit')
          .with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'node-purge-gc-batch-limit', 'value' => '25')
      end

      it { is_expected.to contain_ini_setting('puppetdb_node_ttl').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'node-ttl', 'value' => '7d') }
      it { is_expected.to contain_ini_setting('puppetdb_node_purge_ttl').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'node-purge-ttl', 'value' => '14d') }
      it { is_expected.to contain_ini_setting('puppetdb_report_ttl').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'report-ttl', 'value' => '14d') }
      it { is_expected.to contain_ini_setting('puppetdb_conn_max_age').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'conn-max-age', 'value' => '60') }
      it { is_expected.to contain_ini_setting('puppetdb_conn_lifetime').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'conn-lifetime', 'value' => '0') }
      it { is_expected.to contain_ini_setting('puppetdb_migrate').with('ensure' => 'present', 'path' => ini, 'section' => 'database', 'setting' => 'migrate', 'value' => true) }
      it { is_expected.not_to contain_ini_setting('puppetdb_database_max_pool_size') }
      it { is_expected.to contain_ini_setting('puppetdb_facts_blacklist').with('ensure' => 'absent', 'path' => ini, 'section' => 'database', 'setting' => 'facts-blacklist') }
    end
  end

  describe 'when using facts_blacklist' do
    let(:params) { { 'facts_blacklist' => ['one_fact', 'another_fact'] } }

    it do
      expect(catalogue).to contain_ini_setting('puppetdb_facts_blacklist')
        .with('ensure' => 'present', 'path' => default_ini, 'section' => 'database', 'setting' => 'facts-blacklist', 'value' => 'one_fact, another_fact')
    end
  end

  describe 'when setting max pool size' do
    context 'on current PuppetDB with a numeric value' do
      let(:params) { { 'database_max_pool_size' => 12_345 } }

      it do
        expect(catalogue).to contain_ini_setting('puppetdb_database_max_pool_size')
          .with('ensure' => 'present', 'path' => default_ini, 'section' => 'database', 'setting' => 'maximum-pool-size', 'value' => '12345')
      end
    end

    context 'on current PuppetDB with absent' do
      let(:params) { { 'database_max_pool_size' => 'absent' } }

      it { is_expected.to contain_ini_setting('puppetdb_database_max_pool_size').with('ensure' => 'absent', 'path' => default_ini, 'section' => 'database', 'setting' => 'maximum-pool-size') }
    end

    context 'on PuppetDB 3.2 with a numeric value' do
      let(:pre_condition) { 'class { "puppetdb::globals": version => "3.2.0", }' }
      let(:params) { { 'database_max_pool_size' => 12_345 } }

      it do
        expect(catalogue).to contain_ini_setting('puppetdb_database_max_pool_size')
          .with('ensure' => 'present', 'path' => default_ini, 'section' => 'database', 'setting' => 'partition-conn-max', 'value' => '12345')
      end
    end

    context 'on PuppetDB 3.2 with absent' do
      let(:pre_condition) { 'class { "puppetdb::globals": version => "3.2.0", }' }
      let(:params) { { 'database_max_pool_size' => 'absent' } }

      it { is_expected.to contain_ini_setting('puppetdb_database_max_pool_size').with('ensure' => 'absent', 'path' => default_ini, 'section' => 'database', 'setting' => 'partition-conn-max') }
    end

    context 'on a legacy PuppetDB version with a numeric value' do
      let(:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }
      let(:params) { { 'database_max_pool_size' => 12_345 } }

      it { is_expected.not_to contain_ini_setting('puppetdb_database_max_pool_size') }
    end

    context 'on a legacy PuppetDB version with absent' do
      let(:pre_condition) { 'class { "puppetdb::globals": version => "2.2.0", }' }
      let(:params) { { 'database_max_pool_size' => 'absent' } }

      it { is_expected.not_to contain_ini_setting('puppetdb_database_max_pool_size') }
    end
  end

  describe 'when using ssl communication' do
    let(:params) { { 'postgresql_ssl_on' => true, 'ssl_key_pk8_path' => '/tmp/private_key.pk8' } }
    let(:subname) do
      '//localhost:5432/puppetdb?' \
        'ssl=true&sslfactory=org.postgresql.ssl.LibPQFactory&' \
        'sslmode=verify-full&' \
        'sslrootcert=/etc/puppetlabs/puppetdb/ssl/ca.pem&' \
        'sslkey=/tmp/private_key.pk8&' \
        'sslcert=/etc/puppetlabs/puppetdb/ssl/public.pem'
    end

    it 'configures subname correctly' do
      expect(catalogue).to contain_ini_setting('puppetdb_subname')
        .with(ensure: 'present', path: default_ini, section: 'database', setting: 'subname', value: subname)
    end
  end
end
