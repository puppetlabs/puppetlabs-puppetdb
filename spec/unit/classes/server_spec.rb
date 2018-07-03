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
    end
  end
end
