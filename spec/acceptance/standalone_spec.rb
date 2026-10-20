# frozen_string_literal: true

require 'spec_helper_acceptance'

# ss rather than netstat: net-tools is not installed by default on RedHat
PUPPETDB_READY_COMMAND = 'timeout 300 sh -c "until ss -tln ' \
                         '| grep -q \':8080 \'; do sleep 2; done" || { systemctl status puppetdb ' \
                         '--no-pager; journalctl -u puppetdb --no-pager -n 100; exit 1; }'

describe 'standalone' do
  let(:manage_firewall) { "(getvar('facts.os.family') == 'RedHat' and Integer(getvar('facts.os.release.major')) > 7)" }
  let(:postgres_version) { "(getvar('facts.os.family') == 'Suse') ? { true => '15', default => undef }" }
  let(:puppetdb_master_config_params) { '' }
  let(:puppetdb_params) { '' }

  it_behaves_like 'puppetserver'

  describe 'with defaults' do
    it_behaves_like 'puppetdb'

    describe command(PUPPETDB_READY_COMMAND), :status do
      its(:exit_status) { is_expected.to eq 0 }
    end

    describe service('puppetdb'), :status do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    [8080, 8081].each do |listen_port|
      describe port(listen_port), :status do
        it { is_expected.to be_listening }
      end
    end

    context 'with puppetdb postgres user', :status do
      let(:readonly_create) do
        run_shell('psql "postgresql://puppetdb-read:puppetdb-read@localhost/puppetdb" -c "create table tables(id int)"', expect_failures: true)
      end

      it 'is not allowing read-only user to create tables' do
        expect(readonly_create.stderr).to match(%r{^ERROR:  permission denied for schema public.*})
      end

      it 'fails with exit code 1 when read-only user creates tables' do
        expect(readonly_create.exit_code).to eq 1
      end

      it 'is allowing normal user to manage schema' do
        run_shell('psql "postgresql://puppetdb:puppetdb@localhost/puppetdb" -c "create table testing(id int); drop table testing"') do |r|
          expect(r.exit_status).to eq 0
        end
      end

      it 'is allowing read-only user to select' do
        run_shell('psql "postgresql://puppetdb-read:puppetdb-read@localhost/puppetdb" -c "select * from catalogs limit 1"') do |r|
          expect(r.exit_status).to eq 0
        end
      end
    end
  end

  ['remove', 'add'].each do |outcome|
    context "with manage report processor when it #{outcome}s puppet config puppetdb report processor", :change do
      let(:enable_reports) { (outcome == 'add') }

      let(:puppetdb_master_config_params) do
        <<~PARAMS
          manage_report_processor => true,
          enable_reports          => #{enable_reports},
        PARAMS
      end

      it_behaves_like 'puppetdb'

      describe command('puppet config print --section master reports') do
        its(:stdout) { is_expected.to(satisfy { |out| out.include?('puppetdb') == enable_reports }) }
      end
    end
  end

  describe 'puppetdb with postgresql ssl', :change do
    let(:puppetdb_params) do
      <<~PARAMS
        postgresql_ssl_on       => true,
        database_listen_address => '0.0.0.0',
        database_host           => $facts['networking']['fqdn'],
      PARAMS
    end

    it_behaves_like 'puppetdb'
  end

  describe 'set wrong database password in puppetdb conf', :change do
    let(:pp) do
      <<~PP
        ini_setting { "puppetdb password":
          ensure  => present,
          path    => '/etc/puppetlabs/puppetdb/conf.d/database.ini',
          section => 'database',
          setting => 'password',
          value   => 'random_password',
        }
        ~> service { 'puppetdb':
          ensure => 'running',
        }
      PP
    end

    it 'applies manifest' do
      expect { apply_manifest(pp, expect_failures: false, debug: ENV.key?('DEBUG')) }.not_to raise_error
    end

    describe service('puppetdb') do
      it { is_expected.to be_running }
    end
  end

  describe 'supports changing database port', :change do
    let(:puppetdb_params) do
      <<~PARAMS
        database_port           => '5433',
        read_database_port      => '5433',
      PARAMS
    end

    it_behaves_like 'puppetdb'

    describe port(5433), :status do
      it { is_expected.to be_listening }
    end

    describe service('puppetdb') do
      it { is_expected.to be_running }
    end
  end
end
