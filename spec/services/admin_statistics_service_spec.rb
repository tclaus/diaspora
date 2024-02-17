# frozen literal: true

describe "AdminStatisticsService" do
  let(:service) {AdminStatisticsService.new}

  describe "#total_stat_numbers" do
    before do
      generate_posts
      generate_comments
    end

    context "daily posts stats" do
      it "returns post for today" do
        stats = service.total_stat_numbers
        expect(stats[:day][:local_posts]).to eq(1)
        expect(stats[:day][:total_posts]).to eq(1)
      end

      it "returns comments for today" do
        stats = service.total_stat_numbers
        expect(stats[:day][:local_comments] ).to eq(1)
      end

      it "returns a non empty list of users" do
        stats = service.total_stat_numbers
        expect(stats[:day][:users]).not_to be_nil
      end
    end

    context "weekly posts stats" do
      it "returns posts for this week and for today" do
        stats = service.total_stat_numbers
        expect(stats[:week][:local_posts]).to eq(2)
        expect(stats[:week][:total_posts]).to eq(2)
      end

      it "returns comments for this week and today" do
        stats = service.total_stat_numbers
        expect(stats[:week][:local_comments] ).to eq(2)
      end

      it "returns a non empty list of users" do
        stats = service.total_stat_numbers
        expect(stats[:week][:users]).not_to be_nil
      end
    end

    context "monthly stats" do
      it "returns posts for this month, week and today" do
        stats = service.total_stat_numbers
        expect(stats[:month][:local_posts]).to eq(3)
        expect(stats[:month][:total_posts]).to eq(3)
      end

      it "returns comments for this month, week and today" do
        stats = service.total_stat_numbers
        expect(stats[:month][:local_comments] ).to eq(3)
      end

      it "returns a non empty list of users" do
        stats = service.total_stat_numbers
        expect(stats[:month][:users]).not_to be_nil
      end
    end

    context "yearly stats" do
      it "returns posts for this year, month, week and today" do
        stats = service.total_stat_numbers
        expect(stats[:year][:local_posts]).to eq(4)
        expect(stats[:year][:total_posts]).to eq(4)
      end

      it "returns comments for this year, month, week and today" do
        stats = service.total_stat_numbers
        expect(stats[:year][:local_comments]).to eq(4)
      end

      it "returns a non empty list of users" do
        stats = service.total_stat_numbers
        expect(stats[:year][:users]).not_to be_nil
      end
    end

    context "total stats" do
      it "returns posts before this year, this year, month, week and today" do
        stats = service.total_stat_numbers
        expect(stats[:total][:local_posts]).to eq(5)
        expect(stats[:total][:total_posts]).to eq(5)
      end

      it "returns comments before this year, this year, month, week and today" do
        stats = service.total_stat_numbers
        expect(stats[:total][:local_comments]).to eq(5)
      end

      it "returns a non empty list of users" do
        stats = service.total_stat_numbers
        expect(stats[:total][:users]).not_to be_nil
      end
    end

    context "most active user" do
      it "has user stats for weeks" do
        stats = service.most_active_users
        expect(stats[:week]).not_to be_nil
      end
    end
  end


def generate_posts
  today_post = alice.post(:status_message, text: "ohai", to: alice.aspects.first)
  today_post.save

  last_week_post = alice.post(:status_message, created_at: Time.now - 7.days, text: "ohai", to: alice.aspects.first)
  last_week_post.save

  last_month_post = alice.post(:status_message, created_at: Time.now - 30.days, text: "ohai", to: alice.aspects.first)
  last_month_post.save

  last_year_post = alice.post(:status_message, created_at: Time.now - 365.days, text: "ohai", to: alice.aspects.first)
  last_year_post.save

  @old_post = alice.post(:status_message, created_at: Time.now - 1000.days, text: "ohai", to: alice.aspects.first)
  @old_post.save
end

def generate_comments

  alice.comment!(@old_post, "hello")
  alice.comment!(@old_post, "hello", created_at: Time.now - 7.days)
  alice.comment!(@old_post, "hello", created_at: Time.now - 30.days)
  alice.comment!(@old_post, "hello", created_at: Time.now - 365.days)
  alice.comment!(@old_post, "hello", created_at: Time.now - 999.days)
end
end
