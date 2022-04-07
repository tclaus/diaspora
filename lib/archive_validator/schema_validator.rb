# frozen_string_literal: true

class ArchiveValidator
  class SchemaValidator < BaseValidator
    JSON_SCHEMA = "lib/schemas/archive-format.json"

    def validate
      begin
        return if JSON::Validator.validate!(JSON_SCHEMA, archive_hash)
      rescue JSON::Schema::ValidationError => validation_error
        messages.push("Archive schema validation failed: #{validation_error.message}")
      rescue JSON::Schema::SchemaError => schema_error
        messages.push("Archive schema validation failed: #{schema_error.message}")
      end
    end
  end
end
