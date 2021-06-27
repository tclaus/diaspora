# frozen_string_literal: true

namespace :accounts do
  desc "Perform migration"
  task :migration,
       %i[archive_path photos_path new_user_name import_settings import_profile] => :environment do |_t, args|
    puts "Account migration is requested. You can import a profile or a photos archive or both."
    args = %i[archive_path photos_path new_user_name import_settings import_profile]
           .map {|name| [name, args[name]] }.to_h
    process_arguments(args)

    begin
      service = MigrationService.new(args[:archive_path], args[:new_user_name])
      service.validate
      puts "Warnings:\n#{service.warnings.join("\n")}\n-----" if service.warnings.any?
      if service.only_import?
        puts "Warning: Archive owner is not fetchable. Proceeding with data import, but account migration record "\
          "won't  be created"
      end
      print "Do you really want to execute the archive import? Note: this is irreversible! [y/N]: "
      next unless $stdin.gets.strip.casecmp?("y")

      start_time = Time.now.getlocal
      service.perform!
      puts service.only_import? ? "Data import complete!" : "Data import and migration complete!"
      puts "Migration took #{Time.now.getlocal - start_time} seconds"
    rescue MigrationService::ArchiveValidationFailed => exception
      puts "Errors in the archive found:\n#{exception.message}\n-----"
    rescue MigrationService::MigrationAlreadyExists
      puts "Migration record already exists for the user, can't continue"
    ensure
      service.remove_intermediate_file
    end
    puts "\n Migration finished took #{Time.now.getlocal - start_time} seconds. (Photos might still be processed)"
  end

  def process_arguments(args)
    args[:archive_path] = request_parameter(args[:archive_path], "Enter the archive (.json, .gz, .zip) path: ")
    args[:photos_path] = request_parameter(args[:photos_path], "Enter the photos (.zip) path: ")
    args[:new_user_name] = request_parameter(args[:new_user_name], "Enter the new user name: ")
    args[:import_settings] = request_boolean_parameter(args[:import_settings], "Import and overwrite settings [Y/n]: ")
    args[:import_profile] = request_boolean_parameter(args[:import_profile], "Import and overwrite profile [Y/n]: ")

    puts "Archive path: #{args[:archive_path]}"
    puts "Photos path: #{args[:photos_path]}"
    puts "New username: #{args[:new_user_name]}"
    puts "Import settings: #{args[:import_settings]}"
    puts "Import profile: #{args[:import_profile]}"
  end

  def request_parameter(arg, text)
    return arg unless arg.nil?

    print text
    $stdin.gets.strip
  end

  def request_boolean_parameter(arg, text, default: true)
    return arg == "true" unless arg.nil?

    print text
    response = $stdin.gets.strip.downcase

    return default if response == ""

    response[0] == "y"
  end
end
