require 'spec_helper'

describe 'puppetdb', type: :class do
  ttl_args = ['node_ttl', 'node_purge_ttl', 'report_ttl']

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(selinux: false)
      end

      describe 'when using default values for puppetdb class' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('puppetdb') }
        it { is_expected.to contain_class('puppetdb::server') }
        it { is_expected.to contain_class('puppetdb::database::postgresql') }
      end
    end
    next unless facts[:os]['release']['family'] == 'Debian'
    context "on #{os} with managed postgresql" do
      let :facts do
        facts
      end
      let :params do
        {
          node_ttl: '14d',
          node_purge_ttl: '14d',
          report_ttl: '999d',
          manage_firewall: false,
          manage_dbserver: true,
          postgres_version: '10',
          ssl_set_cert_paths: true,
          disable_update_checking: true,
        }
      end

      describe 'with real world params' do
        it { is_expected.to compile.with_all_deps }
      end
      context "on #{os} without managed postgresql" do
        let :pre_condition do
          <<-HEREDOC
        # get the pg server up and running
        class { 'postgresql::server':
          ip_mask_allow_all_users => '0.0.0.0/0',
          listen_addresses        => '127.0.0.1',
        }
        # get the pg contrib to use pg_trgm extension
        class { 'postgresql::server::contrib': }
        postgresql::server::extension { 'pg_trgm':
          database => 'puppetdb',
          require  => Postgresql::Server::Db['puppetdb'],
        }
        HEREDOC
        end
        let :facts do
          facts
        end
        let :params do
          {
            node_ttl: '14d',
            node_purge_ttl: '14d',
            report_ttl: '999d',
            manage_firewall: false,
            manage_dbserver: false,
            postgres_version: '10',
            ssl_set_cert_paths: true,
            disable_update_checking: true,
          }
        end

        describe 'with real world params' do
          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end

  context 'with invalid arguments on a supported platform' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'Debian',
        puppetversion: Puppet.version,
        operatingsystemrelease: '6.0',
        kernel: 'Linux',
        concat_basedir: '/var/lib/puppet/concat',
        selinux: true,
        iptables_persistent_version: '0.5.7',
      }
    end

    ttl_args.each do |ttl_arg|
      let(:params) do
        {
          ttl_arg => 'invalid_value',
        }
      end

      it "when using a value that does not match the validation regex for #{ttl_arg} puppetdb class" do
        expect { is_expected.to contain_class('puppetdb') }.to raise_error(Puppet::Error)
      end
    end
  end
end
