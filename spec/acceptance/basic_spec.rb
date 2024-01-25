require 'spec_helper_acceptance'

describe 'basic tests' do
  let(:puppetdb_params) {}
  let(:puppetdb_master_config_params) {}
  # FIXME: temporary work-around for EL install
  let(:postgres_version) { "($facts['os']['family'] == 'RedHat') ? { true => '12', default => undef }" }

  let(:pp) do
    <<~EOS
    package { 'puppetserver':
     ensure => installed,
    }
    -> exec { '/opt/puppetlabs/bin/puppetserver ca setup':
      creates => '/etc/puppetlabs/puppetserver/ca/ca_crt.pem',
    }
    ~> service { 'puppetserver':
      ensure => running,
      enable => true,
    }

    class { 'puppetdb':
      postgres_version => #{postgres_version},
      #{puppetdb_params}
    }
    -> class { 'puppetdb::master::config':
      #{puppetdb_master_config_params}
    }
    EOS
  end

  it 'ensure module is installed' do
    # No point diagnosing any more if the module wasn't copied properly
    run_shell('puppet module list') do |r|
      expect(r.stdout).to include(' puppetlabs-puppetdb ')
    end
  end

  describe 'puppetdb' do
    it 'applies idempotently' do
      idempotent_apply(pp)
    end

    describe service('puppetdb') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(8080) do
      it { is_expected.to be_listening.on('127.0.0.1').with('tcp') }
    end

    describe port(8081) do
      it { is_expected.to be_listening.on('0.0.0.0').with('tcp') }
    end

    describe 'puppetdb postgres user' do
      it 'read-only user can not create tables' do
        run_shell('psql "postgresql://puppetdb-read:puppetdb-read@localhost/puppetdb" -c "create table tables(id int)" || true') do |r|
          expect(r.stderr).to match(%r{^ERROR:  permission denied for schema public.*})
        end
      end
    end

    context 'manage report processor', :reports do
      ['add', 'remove'].each do |outcome|
        context "#{outcome}s puppet config puppetdb report processor" do
          let(:enable_reports) { (outcome == 'add') ? true : false }

          let(:puppetdb_master_config_params) do
            <<~EOS
              manage_report_processor => true,
              enable_reports          => #{enable_reports},
            EOS
          end

          it 'applies idempotently' do
            idempotent_apply(pp)
          end

          describe command('puppet config print --section master reports') do
            its(:stdout) do
              option = enable_reports ? 'to' : 'not_to'
              is_expected.method(option).call match 'puppetdb'
            end
          end
        end
      end
    end
  end

  describe 'puppetdb with postgresql ssl' do
    let(:puppetdb_params) do
      <<~EOS
        postgresql_ssl_on       => true,
        database_listen_address => '0.0.0.0',
        database_host           => $facts['networking']['fqdn'],
      EOS
    end

    it 'applies idempotently' do
      idempotent_apply(pp)
    end
  end

  describe 'set wrong database password in puppetdb conf' do
    it 'applies manifest' do
      pp = <<~EOS
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
        EOS

      apply_manifest(pp, expect_failures: false)
    end

    describe service('puppetdb') do
      it { is_expected.to be_running }
    end
  end
end
