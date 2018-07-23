require 'spec_helper'

describe 'puppetdb::server::database', type: :class do
  context 'on a supported platform' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
        operatingsystemrelease: '7.0',
        fqdn: 'test.domain.local',
      }
    end

    describe 'when passing jdbc subparams' do
      let(:params) do
        {
          'jdbc_ssl_properties' => '?ssl=true',
        }
      end

      it {
        is_expected.to contain_ini_setting('puppetdb_subname')
          .with(
            'section' => 'database',
            'setting' => 'subname',
            'value'   => '//localhost:5432/puppetdb?ssl=true',
          )
      }
    end
  end
end
