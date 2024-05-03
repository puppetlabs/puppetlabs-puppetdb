# frozen_string_literal: true

require 'spec_helper'
require 'facter'

describe 'puppetdb_version' do
  subject(:fact) { Facter.fact(:puppetdb_version) }

  before(:each) do
    Facter.clear
  end

  it 'returns the correct puppetdb version' do
    allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return('/usr/bin/puppetdb')
    allow(Facter::Core::Execution).to receive(:execute).with('puppetdb --version').and_return("puppetdb version: 7.18.0\n")

    expect(Facter.fact(:puppetdb_version).value).to eq('7.18.0')
  end

  it 'returns nil if puppetdb command is not available' do
    allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return(nil)

    expect(Facter.fact(:puppetdb_version).value).to be_nil
  end

  it 'returns nil if puppetdb version output is nil' do
    allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return('/usr/bin/puppetdb')
    allow(Facter::Core::Execution).to receive(:execute).with('puppetdb --version').and_return(nil)

    expect(Facter.fact(:puppetdb_version).value).to be_nil
  end
end
