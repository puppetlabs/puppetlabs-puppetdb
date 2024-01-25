require 'metadata_json_lint'

# PDK validate behaviors
MetadataJsonLint.options.fail_on_warnings = true
MetadataJsonLint.options.strict_license = true
MetadataJsonLint.options.strict_puppet_version = true
MetadataJsonLint.options.strict_dependencies = true

PuppetLint.configuration.log_forat = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
PuppetLint.configuration.fail_on_warnings = true

# output task execution
unless Rake.application.options.trace
  setup = ->(task, *_args) do
    puts "===> rake: #{task}"
  end

  task :log_hooker do
    Rake::Task.tasks.reject { |t| t.to_s == 'log_hooker' }.each do |a_task|
      a_task.actions.prepend(setup)
    end
  end
  Rake.application.top_level_tasks.prepend(:log_hooker)
end
