Facter.add(:puppetdb_version) do
  confine { Facter::Util::Resolution.which('puppetdb') }

  setcode do
    output = Facter::Core::Execution.execute('puppetdb --version')

    if output.nil?
      nil
    else
      output.split(':').last.strip
    end
  end
end
