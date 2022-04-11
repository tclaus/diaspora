# frozen_string_literal: true

require "lib/archive_validator/shared"

describe ArchiveValidator::SchemaValidator do
  include_context "validators shared context"

  context "when archive doesn't match the schema" do
    let(:archive_hash) { {} }

    it "contains error" do
      errormessage = validator.messages.first
      expect(errormessage).to start_with("Archive schema validation failed")
    end
  end
end
