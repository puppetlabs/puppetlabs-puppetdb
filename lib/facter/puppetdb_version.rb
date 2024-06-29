# frozen_string_literal: true

Facter.add(:puppetdb_version) do
  confine { Facter::Util::Resolution.which('puppetdb') }

  setcode do
    if Facter.value(:os)['family'] == 'Debian'
      output = Facter::Core::Execution.execute('puppetdb version')
      output.split("\n").first.split('=').last
    else
      output = Facter::Core::Execution.execute('puppetdb --version')
      output.split(':').last.strip
    end
  rescue Facter::Core::Execution::ExecutionFailure
    nil
  end
end
