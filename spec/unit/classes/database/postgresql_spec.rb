require 'spec_helper'

describe 'puppetdb::database::postgresql', type: :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
        puppetversion: Puppet.version,
        operatingsystemrelease: '7.0',
        kernel: 'Linux',
        selinux: true,
        os: {
          family: 'RedHat',
          name: 'RedHat',
          release: { 'full' => '7.0', 'major' => '7' },
          selinux: { 'enabled' => true },
        },
      }
    end

    it { is_expected.to contain_class('puppetdb::database::postgresql') }

    context 'when ssl communication is used' do
      let(:params) do
        {
          postgresql_ssl_on: true,
        }
      end

      it { is_expected.to contain_class('puppetdb::database::ssl_configuration') }
    end

    context 'when ssl communication is not used' do
      let(:params) do
        {
          postgresql_ssl_on: false,
        }
      end

      it { is_expected.not_to contain_class('puppetdb::database::ssl_configuration') }
    end
  end
end
