require 'metadata_json_lint'

# PDK validate behaviors
MetadataJsonLint.options.fail_on_warnings = true
MetadataJsonLint.options.strict_license = true
MetadataJsonLint.options.strict_puppet_version = true
MetadataJsonLint.options.strict_dependencies = true

PuppetLint.configuration.log_forat = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
PuppetLint.configuration.fail_on_warnings = true
