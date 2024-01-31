# frozen_string_literal: true

require 'spec_helper'

describe 'puppetdb::master::storeconfigs', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }
  let(:params) do
    {
      masterless: false,
      enable: true,
    }
  end

  let(:param_ensure) { params[:enable] ? 'present' : 'absent' }
  let(:puppet_conf_section) { params[:masterless] ? 'main' : 'master' }
  let(:puppet_conf) { File.join(Puppet[:confdir], 'puppet.conf') }

  context 'with default parameters' do
    it {
      is_expected.to contain_ini_setting("puppet.conf/#{puppet_conf_section}/storeconfigs")
        .with_ensure(param_ensure)
        .with(
          section: puppet_conf_section,
          path: puppet_conf,
          setting: 'storeconfigs',
          value: true,
        )
    }
    it {
      is_expected.to contain_ini_setting("puppet.conf/#{puppet_conf_section}/storeconfigs_backend")
        .with_ensure(param_ensure)
        .with(
          section: puppet_conf_section,
          path: puppet_conf,
          setting: 'storeconfigs_backend',
          value: 'puppetdb',
        )
    }
  end
end
