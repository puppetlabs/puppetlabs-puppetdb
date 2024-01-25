# frozen_string_literal: true

require 'spec_helper'

shared_examples 'routes master.facts.cache format' do |format|
  it "is expected to set master.facts.cache to equal #{format} in routes.yaml" do
    yaml_data = catalogue.resource('file', "#{params[:puppet_confdir]}/routes.yaml").send(:parameters)[:content]
    parsed = YAML.safe_load(yaml_data, symbolize_names: true)

    expect(parsed[:master][:facts][:cache]).to eq format.to_s
  end
end

describe 'puppetdb::master::routes', type: :class do
  let(:facts) { on_supported_os.take(1).first[1] }
  let(:params) do
    {
      puppet_confdir: Puppet[:confdir],
      masterless:     false,
    }
  end

  let(:serverversion) { Puppet.version }

  let(:routes_real) do
    if params[:masterless]
      {
        apply: {
          catalog: {
            terminus: 'compiler',
            cache:    'puppetdb',
          },
          facts: {
            terminus: 'facter',
            cache:    'puppetdb_apply',
          },
        },
      }
    elsif params[:routes]
      params[:routes]
    else
      {
        master: {
          facts: {
            terminus: 'puppetdb',
            cache: (Puppet::Util::Package.versioncmp(serverversion, '7.0') >= 0) ? 'json' : 'yaml'
          },
        }
      }
    end
  end

  context 'with defaults' do
    it {
      is_expected.to contain_file("#{params[:puppet_confdir]}/routes.yaml")
        .with(
          ensure:  'file',
          mode:    '0644',
        )
    }

    it {
      yaml_data = catalogue.resource('file', "#{params[:puppet_confdir]}/routes.yaml").send(:parameters)[:content]
      parsed = YAML.safe_load(yaml_data, symbolize_names: true)

      expect(parsed).to eq routes_real
    }
  end

  # TODO: remove puppetserver 6 support
  #       unable to easily test puppetserver 6 with rspec
  #       and it's not a supported version
  context "with puppetserver version #{Puppet.version}" do
    include_examples 'routes master.facts.cache format', :json
  end
end
