# frozen_string_literal: true

require 'spec_helper'
require 'facter'
require 'open3'

describe 'puppetdb_version' do
  subject(:fact) { Facter.fact(:puppetdb_version) }

  before(:each) do
    Facter.clear
  end

  it 'returns a version on non-Debian family with puppetlabs package' do
    allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return('/usr/bin/puppetdb')
    allow(Open3).to receive(:capture2).with('puppetdb --version').and_return("puppetdb version: 7.18.0\n")

    expect(Facter.fact(:puppetdb_version).value).to eq('7.18.0')
  end

  it 'returns a version on Debian family with non-puppetlabs package' do
    allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return('/usr/sbin/puppetdb')
    allow(Facter).to receive(:value).with(:osfamily).and_return('Debian')
    allow(Facter::Core::Execution).to receive(:execute).with('apt-cache show puppetdb | grep "Maintainer:" | head -1').and_return('Maintainer: Ubuntu Developers')
    allow(Open3).to receive(:capture2).with('dpkg-query --showformat=\'${Version}\' --show puppetdb').and_return("6.2.0-5")

    expect(Facter.fact(:puppetdb_version).value).to eq('6.2.0')
  end

  it 'returns a version on Debian family with puppetlabs package' do
    allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return('/usr/sbin/puppetdb')
    allow(Facter).to receive(:value).with(:osfamily).and_return('Debian')
    allow(Facter::Core::Execution).to receive(:execute).with('apt-cache show puppetdb | grep "Maintainer:" | head -1').and_return('Maintainer: Puppet Labs')
    allow(Open3).to receive(:capture2).with('dpkg-query --showformat=\'${Version}\' --show puppetdb').and_return("7.19.0-1jammy")

    expect(Facter.fact(:puppetdb_version).value).to eq('7.19.0')
  end

  it 'returns nil if puppetdb command is not available' do
    allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return(nil)

    expect(Facter.fact(:puppetdb_version).value).to be_nil
  end
end
