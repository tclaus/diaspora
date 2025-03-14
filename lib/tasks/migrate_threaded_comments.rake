# frozen_string_literal: true


namespace "comments" do
  desc "Extract thread information from comment-signatures"
  task migrate_threaded: :environment do
    puts "Extracts threaded information from comments when fetched from a system that supports threaded comments"
    extract_and_migrate_threaded_information
  end

  def extract_and_migrate_threaded_information
    comment_signatures_with_data = CommentSignature
            .where.not(additional_data: nil)

    migrate_comments(comment_signatures_with_data)
    puts "Finished"
  end

  def migrate_comments(comment_signatures_with_data)
    puts "Found #{comment_signatures_with_data.count} comments with data to examine for threaded data"
    migrated_comments = 0
    comment_signatures_with_data.find_each do |possible_comment_to_migrate|
      extract_thread_parent_guid(possible_comment_to_migrate)

      migrated_comments+=1
      write_progress(migrated_comments)
    end
  end

  def write_progress(migrated_comments)
    if migrated_comments % 100 == 0
      puts "Finished #{migrated_comments}"
    end
  end

  def extract_thread_parent_guid(possible_comment_to_migrate)
    thread_parent_guid = possible_comment_to_migrate.additional_data["thread_parent_guid"]
    return unless thread_parent_guid.present?

    update_thread_parent_guid(possible_comment_to_migrate.comment, thread_parent_guid)
  end

  def update_thread_parent_guid(comment, thread_parent_guid)
    return unless comment

    comment.thread_parent_guid = thread_parent_guid
    comment.save(touch: false)
  end
end

