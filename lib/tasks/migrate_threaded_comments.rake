# frozen_string_literal: true

<<<<<<< HEAD

=======
>>>>>>> 3f5d91bd891288f84981e8a573661be03bfd4ef5
namespace "comments" do
  desc "Extract thread information from comments"
  task migrate_threaded: :environment do
    puts "Extracts threaded information from comments when fetched from a system that supports threaded comments"
<<<<<<< HEAD
    extract_and_migrate_threaded_information
  end

  def extract_and_migrate_threaded_information
=======
    extract_and_migrate
  end

  def extract_and_migrate
>>>>>>> 3f5d91bd891288f84981e8a573661be03bfd4ef5
    comment_signatures_with_data = CommentSignature
            .where.not(additional_data: nil)

    migrate_comments(comment_signatures_with_data)
    puts "Finished"
  end

<<<<<<< HEAD
  def migrate_comments(comment_signatures_with_data)
    puts "Found #{comment_signatures_with_data.count} comments with data to examine for threaded data"
    migrated_comments = 0
    comment_signatures_with_data.find_each do |possible_comment_to_migrate|
      extract_thread_parent_guid(possible_comment_to_migrate)

      migrated_comments+=1
=======
  def migrate_comments(comment_signatures)
    puts "Found #{comment_signatures.count} comments with data to examine for threaded data"
    migrated_comments = 0
    comment_signatures.find_each do |possible_comment_to_migrate|
      extract_thread_parent_guid(possible_comment_to_migrate)

      migrated_comments += 1
>>>>>>> 3f5d91bd891288f84981e8a573661be03bfd4ef5
      write_progress(migrated_comments)
    end
  end

  def extract_thread_parent_guid(possible_comment_to_migrate)
<<<<<<< HEAD
    thread_parent_guid = possible_comment_to_migrate.additional_data[:thread_parent_guid]
=======
    thread_parent_guid = possible_comment_to_migrate.additional_data["thread_parent_guid"]
>>>>>>> 3f5d91bd891288f84981e8a573661be03bfd4ef5
    if thread_parent_guid.present?
      comment = possible_comment_to_migrate.comment
      comment&.thread_parent_guid = thread_parent_guid
      comment&.save(touch: false)
    end
  end

  def write_progress(migrated_comments)
<<<<<<< HEAD
    if migrated_comments % 100 == 0
      puts "Finished #{migrated_comments}"
    end
  end

end

=======
    puts "Finished #{migrated_comments}" if migrated_comments % 100 == 0
  end
end
>>>>>>> 3f5d91bd891288f84981e8a573661be03bfd4ef5
