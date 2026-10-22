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

  let(:puppet_conf_section) { params[:masterless] ? 'main' : 'server' }

  context 'with default parameters' do
    let(:setting_params) { { ensure: 'present', section: puppet_conf_section, path: File.join(Puppet[:confdir], 'puppet.conf') } }

    it { is_expected.to contain_ini_setting("puppet.conf/#{puppet_conf_section}/storeconfigs").with(setting_params.merge(setting: 'storeconfigs', value: true)) }

    it do
      expect(catalogue).to contain_ini_setting("puppet.conf/#{puppet_conf_section}/storeconfigs_backend")
        .with(setting_params.merge(setting: 'storeconfigs_backend', value: 'puppetdb'))
    end
  end
end
