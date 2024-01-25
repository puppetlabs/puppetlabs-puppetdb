require 'spec_helper'

describe 'puppetdb::globals', type: :class do
  # loop required to test fail function
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }

      include_examples 'puppetdb::globals'
    end
  end

  context 'on other os' do
    include_examples 'puppetdb::globals', %r{puppetdb does not support your os} do
      let(:facts) { { os: { 'family' => 'Nonsense' } } }
    end
  end

  context 'on invalid confdir' do
    include_examples 'puppetdb::globals', Puppet::ParseError do
      let(:params) { { puppet_confdir: './relative' } }
    end
  end
end
