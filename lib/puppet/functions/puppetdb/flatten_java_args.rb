Puppet::Functions.create_function(:'puppetdb::flatten_java_args') do
  dispatch :flatten_java_args do
    optional_param 'Hash', :java_args
    return_type 'String'
  end

  def flatten_java_args(java_args = {})
    args = ''
    java_args.each { |k, v| args += "#{k}#{v} " }
    "\"#{args.chomp(' ')}\""
  end
end
