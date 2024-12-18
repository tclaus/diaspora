# frozen_string_literal: true

describe Spam::SpamRating do
  let(:user) { create(:user) }
  let(:service) { described_class.new(user) }

  describe "#spam_score" do
    it "returns 0 when the user has no messages" do
      expect(service.spam_score).to eq(0)
    end

    it "calculates the correct score when messages exist" do
      create_list(:status_message, 5, author: user.person, spam: true)
      create_list(:status_message, 5, author: user.person, spam: false)
      expect(service.spam_score).to eq(0.5)
    end
  end
end
