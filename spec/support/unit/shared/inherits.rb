# frozen_string_literal: true

shared_examples 'puppetdb::params' do
  include_examples 'puppetdb::globals'

  it { is_expected.to contain_class('puppetdb::params') }
end

shared_examples 'puppetdb::globals' do |error = false|
  let(:defaults) do
    {
      version: 'present',
      database: 'postgres',
      puppet_confdir: Puppet[:confdir],
    }
  end

  let(:with) { defaults.merge(defined?(args) ? args : {}) }

  it {
    if error
      is_expected.to raise_error(error)
    else
      is_expected.to contain_class('puppetdb::globals').with(with)
    end
  }
end
