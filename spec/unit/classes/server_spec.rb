require 'spec_helper'

describe 'puppetdb::server', type: :class do
  let :node do
    'test.domain.local'
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(puppetversion: Puppet.version,
                    selinux: true)
      end

      pathdir = case facts[:osfamily]
                when 'Debian'
                  '/etc/default/puppetdb'
                else
                  '/etc/sysconfig/puppetdb'
                end

      describe 'when using default values' do
        it { is_expected.to contain_class('puppetdb::server') }
        it { is_expected.to contain_class('puppetdb::server::global') }
        it { is_expected.to contain_class('puppetdb::server::command_processing') }
        it { is_expected.to contain_class('puppetdb::server::database') }
        it { is_expected.to contain_class('puppetdb::server::read_database') }
        it { is_expected.to contain_class('puppetdb::server::jetty') }
        it { is_expected.to contain_class('puppetdb::server::puppetdb') }
      end

      describe 'when not specifying JAVA_ARGS' do
        it { is_expected.not_to contain_ini_subsetting('Xms') }
      end

      describe 'when specifying JAVA_ARGS' do
        let(:params) do
          {
            'java_args' => {
              '-Xms' => '2g',
            },
          }
        end

        context 'on redhat PuppetDB' do
          it {
            is_expected.to contain_ini_subsetting("'-Xms'")
              .with(
                'ensure'            => 'present',
                'path'              => pathdir.to_s,
                'section'           => '',
                'key_val_separator' => '=',
                'setting'           => 'JAVA_ARGS',
                'subsetting'        => '-Xms',
                'value'             => '2g',
              )
          }
        end
      end

      describe 'when specifying JAVA_ARGS with merge_default_java_args false' do
        let(:params) do
          {
            'java_args' => { '-Xms' => '2g' },
            'merge_default_java_args' => false,
          }
        end

        context 'on standard PuppetDB' do
          it {
            is_expected.to contain_ini_setting('java_args')
              .with(
                'ensure' => 'present',
                'path' => pathdir.to_s,
                'section' => '',
                'setting' => 'JAVA_ARGS',
                'value' => '"-Xms2g"',
              )
          }
        end
      end

      context 'when systemd is available' do
        let(:facts) do
          facts.merge(systemd: true)
        end

        describe 'by default dlo cleanup service is enabled' do
          it { is_expected.to contain_systemd__unit_file('puppetdb-dlo-cleanup.service').with_content(%r{/opt/puppetlabs/server/data/puppetdb/stockpile/discard/}) }
          it { is_expected.to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer').with_enable(true).with_active(true) }

          it { is_expected.not_to contain_cron('puppetdb-dlo-cleanup') }
        end

        describe 'dlo cleanup service can be disabled by params' do
          let(:params) do
            {
              'automatic_dlo_cleanup' => false,
            }
          end

          it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.service') }
          it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer') }
          it { is_expected.not_to contain_cron('puppetdb-dlo-cleanup') }
        end

        describe 'dlo directory is customized by $vardir to $vardir/stockpile/discard' do
          let(:params) do
            {
              'vardir' => '/var/custom/path',
            }
          end

          it { is_expected.to contain_systemd__unit_file('puppetdb-dlo-cleanup.service').with_content(%r{/var/custom/path/stockpile/discard/}) }
          it { is_expected.to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer').with_enable(true).with_active(true) }

          it { is_expected.not_to contain_cron('puppetdb-dlo-cleanup') }
        end
      end

      context 'when systemd is not available' do
        describe 'by default dlo cleanup is set up with cron' do
          it { is_expected.to contain_cron('puppetdb-dlo-cleanup').with_ensure('present').with(command: %r{/opt/puppetlabs/server/data/puppetdb/stockpile/discard/}) }

          it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.service') }
          it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer') }
        end

        describe 'dlo cleanup can be disabled by params' do
          let(:params) do
            {
              'automatic_dlo_cleanup' => false,
            }
          end

          it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.service') }
          it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer') }
          it { is_expected.not_to contain_cron('puppetdb-dlo-cleanup') }
        end

        describe 'dlo directory is customized by $vardir to $vardir/stockpile/discard' do
          let(:params) do
            {
              'vardir' => '/var/custom/path',
            }
          end

          it { is_expected.to contain_cron('puppetdb-dlo-cleanup').with_ensure('present').with(command: %r{/var/custom/path/stockpile/discard/}) }

          it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.service') }
          it { is_expected.not_to contain_systemd__unit_file('puppetdb-dlo-cleanup.timer') }
        end
      end

      context 'when not managing the database password' do
        let(:params) do
          {
            'manage_db_password' => false,
            'manage_read_db_password' => false,
            'read_database_host' => '10.0.0.1', # Make sure the read_database class is enforced.
          }
        end

        describe 'ini_setting entries for the password will not exist' do
          it { is_expected.to contain_class('puppetdb::server::database').with('manage_db_password' => false) }
          it { is_expected.to contain_class('puppetdb::server::read_database').with('manage_db_password' => false) }

          it { is_expected.not_to contain_ini__setting('puppetdb_psdatabase_password') }
          it { is_expected.not_to contain_ini__setting('puppetdb_read_database_password') }
        end
      end

      context 'when managing ssl communication' do
        let(:params) do
          {
            postgresql_ssl_on: true,
          }
        end
        let(:key_path) { '/etc/puppetlabs/puppetdb/ssl/private.pem' }
        let(:key_pk8_path) { '/etc/puppetlabs/puppetdb/ssl/private.pk8' }

        context 'ini_setting entries for the ssl configuration will exist' do
          it { is_expected.to contain_class('puppetdb::server::database').with('postgresql_ssl_on' => true) }
          it { is_expected.to contain_class('puppetdb::server::database').with(ssl_key_pk8_path: key_pk8_path) }

          it { is_expected.to contain_class('puppetdb::server::read_database').with('postgresql_ssl_on' => true) }
          it { is_expected.to contain_class('puppetdb::server::read_database').with(ssl_key_pk8_path: key_pk8_path) }
        end

        context 'private key file is converted from .pem to .pk8 format' do
          it 'runs exec command' do
            is_expected.to contain_exec(key_pk8_path)
              .with(
                path: ['/opt/puppetlabs/puppet/bin', facts[:path]],
                command: "openssl pkcs8 -topk8 -inform PEM -outform DER -in #{key_path} -out #{key_pk8_path} -nocrypt",
                onlyif: "test ! -e '#{key_pk8_path}' -o '#{key_pk8_path}' -ot '#{key_path}'",
                before: "File[#{key_pk8_path}]",
              )
          end

          it 'contains file private.pk8' do
            is_expected.to contain_file('/etc/puppetlabs/puppetdb/ssl/private.pk8')
              .with(
                ensure: 'present',
                owner: 'puppetdb',
                group: 'puppetdb',
                mode: '0600',
              )
          end
        end
      end
    end
  end
end
