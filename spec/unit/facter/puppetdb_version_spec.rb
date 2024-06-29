# frozen_string_literal: true

require 'facter'

describe 'puppetdb_version' do
  before(:each) do
    Facter.clear
  end

  context 'when puppetdb is available' do
    before(:each) do
      allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return('/usr/bin/puppetdb')
    end

    context 'on a default system' do
      before(:each) do
        allow(Facter).to receive(:value).with(:os).and_return('family' => 'RedHat')
      end
      it 'returns the correct version from puppetdb --version' do
        allow(Facter::Core::Execution).to receive(:execute).with('puppetdb --version').and_return('puppetdb version: 7.19.0')

        expect(Facter.fact(:puppetdb_version).value).to eq('7.19.0')
      end

      it 'returns nil if the command execution fails' do
        allow(Facter::Core::Execution).to receive(:execute).with('puppetdb --version').and_raise(Facter::Core::Execution::ExecutionFailure)

        expect(Facter.fact(:puppetdb_version).value).to be_nil
      end
    end

    context 'on Debian' do
      before(:each) do
        allow(Facter).to receive(:value).with(:os).and_return('family' => 'Debian')
      end
      it 'returns the correct version from puppetdb version' do
        allow(Facter::Core::Execution).to receive(:execute).with('puppetdb version').and_return("version=8.4.1\ntarget_schema_version=84")

        expect(Facter.fact(:puppetdb_version).value).to eq('8.4.1')
      end

      it 'returns nil if the command execution fails' do
        allow(Facter::Core::Execution).to receive(:execute).with('puppetdb version').and_raise(Facter::Core::Execution::ExecutionFailure)

        expect(Facter.fact(:puppetdb_version).value).to be_nil
      end
    end
  end

  context 'when puppetdb is not available' do
    before(:each) do
      allow(Facter::Util::Resolution).to receive(:which).with('puppetdb').and_return(nil)
    end

    it 'returns nil' do
      expect(Facter.fact(:puppetdb_version).value).to be_nil
    end
  end
end
