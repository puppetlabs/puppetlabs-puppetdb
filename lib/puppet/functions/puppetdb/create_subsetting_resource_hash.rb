Puppet::Functions.create_function(:'puppetdb::create_subsetting_resource_hash') do
  dispatch :create_subsetting_resource_hash do
    required_param 'Hash', :java_args
    required_param 'Any', :params
  end

  def create_subsetting_resource_hash(java_args, params)
    resource_hash = {}

    java_args.each do |k, v|
      item_params = { 'subsetting' => k, 'value' => (v || '') }
      item_params.merge!(params)
      resource_hash.merge!("'#{k}'" => item_params)
    end

    resource_hash
  end
end
