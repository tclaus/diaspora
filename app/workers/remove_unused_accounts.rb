# frozen_string_literal: true

module Workers
  class RemoveUnusedAccounts < Base
    sidekiq_options queue: :low
    # Unused accounts did register once but never interacted with this pod.
    # After a time of peace they will be deleted
    def perform
      users = unused_accounts
      close_accounts(users)
    end

    private

    def unused_accounts
      older_than = Time.current - 30.days
      max_sign_ins = 2
      User.find_by_sql(["select users.* from users, people
              where people.owner_id = users.id and people.closed_account = false and
              (select count(*) from posts where posts.author_id = people.id) = 0 and
              (select count(*) from comments where author_id = people.id) = 0 and
              (select count(*) from likes where author_id = people.id) = 0 and
              (users.last_seen::Date - users.created_at::Date) < 2 and
              users.created_at < ? and
              users.sign_in_count < ?", older_than, max_sign_ins])
    end

    def close_accounts(users)
      logger.info("Removing #{users.size} unused and dead accounts") unless users.empty?
      users.each(&:close_account!)
    end
  end
end
