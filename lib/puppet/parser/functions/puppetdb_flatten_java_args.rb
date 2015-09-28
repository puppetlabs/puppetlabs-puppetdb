module Puppet::Parser::Functions
  newfunction(:puppetdb_flatten_java_args, :type => :rvalue) do |args|
    java_args = args[0] || {}
    args = ""
    java_args.each {|k,v| args += "#{k}#{v} "}
    "\"#{args.chomp(' ')}\""
  end
end
