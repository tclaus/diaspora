# frozen_string_literal: true

describe Workers::RemoveUnusedAccounts do
  describe "#perform" do
    it "removes old unused accounts while let others untouched" do

      alice.post(:status_message, text: "AWESOME", to: alice.aspects.first.id)
      bob.created_at = Time.current - 45.days
      bob.last_seen = Time.current - 45.days
      bob.save(touch: false)

      Workers::RemoveUnusedAccounts.new.perform
      # expect alice untouched
      # bob removed
      # user = FactoryBot.create(:user, last_seen: Time.zone.now - 728.days, sign_in_count: 5)

      expect(AccountDeletion.exists?(person: bob.person)).to be_truthy
      expect(AccountDeletion.exists?(person: alice.person)).to be_falsey
    end

    it "wont remove old accounts woth posts" do

      bob.post(:status_message, text: "AWESOME", to: alice.aspects.first.id)
      bob.created_at = Time.current - 46.days
      bob.last_seen = Time.current - 45.days
      bob.save(touch: false)

      Workers::RemoveUnusedAccounts.new.perform
      # expect alice untouched
      # bob removed
      # user = FactoryBot.create(:user, last_seen: Time.zone.now - 728.days, sign_in_count: 5)

      expect(AccountDeletion.exists?(person: bob.person)).to be_falsey
    end
  end
end
