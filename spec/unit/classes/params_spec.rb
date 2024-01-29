require 'spec_helper'

describe 'puppetdb::params', type: :class do
  # loop required to test fail function
  on_supported_os.each do |os, facts|
    let(:facts) { facts }
    context "on #{os}" do
      it { is_expected.to contain_class('puppetdb::globals') }
    end
  end
end
