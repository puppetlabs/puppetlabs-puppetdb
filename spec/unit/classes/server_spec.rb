# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::server', type: :class do
  let :node do
    'test.domain.local'
  end

  let(:pathdir) do
    case facts[:os]['family']
    when 'Debian'
      '/etc/default/puppetdb'
    else
      '/etc/sysconfig/puppetdb'
    end
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      context 'when using default values' do
        it { is_expected.to contain_class('puppetdb::server') }
        it { is_expected.to contain_class('puppetdb::server::global') }
        it { is_expected.to contain_class('puppetdb::server::command_processing') }
        it { is_expected.to contain_class('puppetdb::server::database') }
        it { is_expected.to contain_class('puppetdb::server::read_database') }
        it { is_expected.to contain_class('puppetdb::server::jetty') }
        it { is_expected.to contain_class('puppetdb::server::puppetdb') }
        it { is_expected.to contain_package('puppetdb').that_notifies('Service[puppetdb]') }
        it { is_expected.to contain_service('puppetdb').with_ensure('running').with_enable(true) }
      end

      context 'when not specifying JAVA_ARGS' do
        it { is_expected.not_to contain_ini_subsetting('Xms') }
      end

      context 'when specifying JAVA_ARGS' do
        let(:params) do
          {
            'java_args' => {
              '-Xms' => '2g',
            },
          }
        end

        it do
          expect(catalogue).to contain_ini_subsetting("'-Xms'")
            .with('ensure' => 'present', 'path' => pathdir.to_s, 'section' => '', 'key_val_separator' => '=', 'setting' => 'JAVA_ARGS', 'subsetting' => '-Xms', 'value' => '2g')
        end
      end

      context 'when specifying JAVA_ARGS with merge_default_java_args false' do
        let(:params) do
          {
            'java_args' => { '-Xms' => '2g' },
            'merge_default_java_args' => false,
          }
        end

        it { is_expected.to contain_ini_setting('java_args').with('ensure' => 'present', 'path' => pathdir.to_s, 'section' => '', 'setting' => 'JAVA_ARGS', 'value' => '"-Xms2g"') }
      end

      context 'when systemd is available' do
        let(:facts) do
          super().merge(systemd: true)
        end

        it { is_expected.to contain_systemd__unit_file('puppetdb-dlo-cleanup.service').with_content(%r{/opt/puppetlabs/server/data/puppetdb/stockpile/discard/}) }
        it { is_expected.to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer').with_enable(true).with_active(true) }

        it { is_expected.not_to contain_cron('puppetdb-dlo-cleanup') }
      end

      context 'when systemd is available and dlo cleanup is disabled by params' do
        let(:facts) do
          super().merge(systemd: true)
        end
        let(:params) do
          {
            'automatic_dlo_cleanup' => false,
          }
        end

        it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.service') }
        it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer') }
        it { is_expected.not_to contain_cron('puppetdb-dlo-cleanup') }
      end

      context 'when systemd is available and the dlo directory is customized by $vardir' do
        let(:facts) do
          super().merge(systemd: true)
        end
        let(:params) do
          {
            'vardir' => '/var/custom/path',
          }
        end

        it { is_expected.to contain_systemd__unit_file('puppetdb-dlo-cleanup.service').with_content(%r{/var/custom/path/stockpile/discard/}) }
        it { is_expected.to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer').with_enable(true).with_active(true) }

        it { is_expected.not_to contain_cron('puppetdb-dlo-cleanup') }
      end

      context 'when systemd is not available' do
        it { is_expected.to contain_cron('puppetdb-dlo-cleanup').with_ensure('present').with(command: %r{/opt/puppetlabs/server/data/puppetdb/stockpile/discard/}) }

        it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.service') }
        it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer') }
      end

      context 'when systemd is not available and dlo cleanup is disabled by params' do
        let(:params) do
          {
            'automatic_dlo_cleanup' => false,
          }
        end

        it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.service') }
        it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer') }
        it { is_expected.not_to contain_cron('puppetdb-dlo-cleanup') }
      end

      context 'when systemd is not available and the dlo directory is customized by $vardir' do
        let(:params) do
          {
            'vardir' => '/var/custom/path',
          }
        end

        it { is_expected.to contain_cron('puppetdb-dlo-cleanup').with_ensure('present').with(command: %r{/var/custom/path/stockpile/discard/}) }

        it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.service') }
        it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer') }
      end

      context 'when not managing the database password' do
        let(:params) do
          {
            'manage_db_password' => false,
            'manage_read_db_password' => false,
            'read_database_host' => '10.0.0.1', # Make sure the read_database class is enforced.
          }
        end

        it { is_expected.to contain_class('puppetdb::server::database').with('manage_db_password' => false) }
        it { is_expected.to contain_class('puppetdb::server::read_database').with('manage_db_password' => false) }

        it { is_expected.not_to contain_ini__setting('puppetdb_psdatabase_password') }
        it { is_expected.not_to contain_ini__setting('puppetdb_read_database_password') }
      end

      context 'when managing ssl communication' do
        let(:params) do
          {
            postgresql_ssl_on: true,
          }
        end

        def key_path
          '/etc/puppetlabs/puppetdb/ssl/private.pem'
        end

        def key_pk8_path
          '/etc/puppetlabs/puppetdb/ssl/private.pk8'
        end

        it { is_expected.to contain_class('puppetdb::server::database').with('postgresql_ssl_on' => true) }
        it { is_expected.to contain_class('puppetdb::server::database').with(ssl_key_pk8_path: key_pk8_path) }

        it { is_expected.to contain_class('puppetdb::server::read_database').with('postgresql_ssl_on' => true) }
        it { is_expected.to contain_class('puppetdb::server::read_database').with(ssl_key_pk8_path: key_pk8_path) }

        it 'converts the private key file from .pem to .pk8 format' do
          expect(catalogue).to contain_exec(key_pk8_path).with(path: ['/opt/puppetlabs/puppet/bin', facts[:path]],
                                                               command: "openssl pkcs8 -topk8 -inform PEM -outform DER -in #{key_path} -out #{key_pk8_path} -nocrypt",
                                                               onlyif: "test ! -e '#{key_pk8_path}' -o '#{key_pk8_path}' -ot '#{key_path}'",
                                                               before: "File[#{key_pk8_path}]")
        end

        it { is_expected.to contain_file(key_pk8_path).with(ensure: 'file', owner: 'root', group: 'puppetdb', mode: '0640') }
      end
    end
  end
end
