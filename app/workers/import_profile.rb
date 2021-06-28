# frozen_string_literal: true

module Workers
  class ImportProfile < Base
    sidekiq_options queue: :medium

    include Diaspora::Logging

    def perform(user_id)
      user = User.find_by(username: user_id)
      if user.nil?
        logger.error "A user with name #{user_id} not a local user"
      else
        logger.debug "Import for profile #{user_id} at path #{user.export.current_path} requested"
        import_user_profile(user.export.current_path, user_id)
      end
    end

    def import_user_profile(path_to_profile, username)
      service = MigrationService.new(path_to_profile, username)
      logger.info "Start validating user profile #{username}"
      service.validate
      logger.info "Start importing user profile for #{username}"
      service.perform!
      logger.info "Successfully imported profile: #{username}"
    rescue MigrationService::ArchiveValidationFailed => e
      logger.error "Errors in the archive found: #{e.message}"
    rescue MigrationService::MigrationAlreadyExists
      logger.error "Migration record already exists for the user, can't continue"
    rescue MigrationService::SelfMigrationNotAllowed
      logger.error "You can't migrate onto your own account"
    ensure
      service.remove_intermediate_file
    end
  end
end
