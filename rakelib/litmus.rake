# frozen_string_literal: true

litmus_cleanup = false
at_exit { Rake::Task['litmus:tear_down'].invoke if litmus_cleanup }

desc "Provision machines, run acceptance tests, and tear down\n(defaults: group=default, tag=nil)"
task :acceptance, [:group, :tag] do |_task, args|
  args.with_defaults(group: 'default', tag: nil)
  Rake::Task['spec_prep'].invoke
  litmus_cleanup = ENV.fetch('LITMUS_teardown', 'true').downcase.match?(%r{(true|auto)})
  Rake::Task['litmus:provision_list'].invoke args[:group]
  Rake::Task['litmus:install_agent'].invoke
  Rake::Task['litmus:install_modules'].invoke
  begin
    Rake::Task['litmus:acceptance:parallel'].invoke args[:tag]
  rescue SystemExit
    litmus_cleanup = false if ENV.fetch('LITMUS_teardown', '').casecmp('auto').zero?
    raise
  end
end

namespace :litmus do
  desc "Run tests against all nodes in the litmus inventory\n(defaults: tag=nil)"
  task :acceptance, [:tag] do |_task, args|
    args.with_defaults(tag: nil)

    Rake::Task.tasks.select { |t| t.to_s =~ %r{^litmus:acceptance:(?!(localhost|parallel)$)} }.each do |litmus_task|
      puts "Running task #{litmus_task}"
      litmus_task.invoke(*args)
    end
  end

  desc "install all fixture modules\n(defaults: resolve_dependencies=false)"
  task :install_modules_from_fixtures, [:resolve_dependencies] do |_task, args|
    args.with_defaults(resolve_dependencies: false)

    Rake::Task['spec_prep'].invoke
    Rake::Task['litmus:install_modules_from_directory'].invoke(nil, nil, nil, !args[:resolve_dependencies])
  end
end
