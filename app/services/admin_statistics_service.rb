# frozen_string_literal: true

class AdminStatisticsService
  DAY = 1
  WEEKDAYS = 7
  MONTHDAYS = 30
  YEAR = 365

  def total_stat_numbers_cached
    Rails.cache.fetch("admin/stats", expires_in: 1.hour) do
      total_stat_numbers
    end
  end

  def total_stat_numbers
    stats = {}
    stats[:day] = {}
    stats[:week] = {}
    stats[:month] = {}
    stats[:year] = {}

    stats[:day][:local_posts] = posts_local_since(DAY)
    stats[:day][:total_posts] = posts_since(DAY)
    stats[:week][:local_posts] = posts_local_since(WEEKDAYS)
    stats[:week][:total_posts] = posts_since(WEEKDAYS)
    stats[:month][:local_posts] = posts_local_since(MONTHDAYS)
    stats[:month][:total_posts] = posts_since(MONTHDAYS)
    stats[:year][:local_posts] = posts_local_since(YEAR)
    stats[:year][:total_posts] = posts_since(YEAR)

    stats[:day][:local_comments] = comments_local_since(DAY)
    stats[:day][:total_comments] = comments_since(DAY)
    stats[:week][:local_comments] = comments_local_since(WEEKDAYS)
    stats[:week][:total_comments] = comments_since(WEEKDAYS)
    stats[:month][:local_comments] = comments_local_since(MONTHDAYS)
    stats[:month][:total_comments] = comments_since(MONTHDAYS)
    stats[:year][:local_comments] = comments_local_since(YEAR)
    stats[:year][:total_comments] = comments_since(YEAR)

    stats[:week][:users] = users_since(WEEKDAYS)
    stats[:day][:users] = users_since(DAY)
    stats[:month][:users] = users_since(MONTHDAYS)
    stats[:year][:users] = users_since(YEAR)

    stats
  end

  def popular_tags_cached
    Rails.cache.fetch("admin/stats/tags", expires_in: 1.hour) do
      popular_tags
    end
  end

  def popular_tags
    tags = {}
    tags[:day] = popular_tags_since(DAY)
    tags[:week] = popular_tags_since(WEEKDAYS)
    tags[:month] = popular_tags_since(MONTHDAYS)
    tags
  end

  def posts_stats_cached
    Rails.cache.fetch("admin/stats/posts", expires_in: 1.hour) do
      posts_stats
    end
  end

  def posts_stats
    posts = {}
    posts[:by_language] = {}
    posts[:by_language][:month] = posts_by_language_since(MONTHDAYS)
    posts[:by_language][:total] = posts_by_language

    posts[:most_liked] = {}
    posts[:most_liked][:day] = most_liked_posts_since(DAY)
    posts[:most_liked][:month] = most_liked_posts_since(MONTHDAYS)

    posts[:most_commented] = {}
    posts[:most_commented][:day] = most_comments_posts_since(DAY)
    posts[:most_commented][:month] = most_comments_posts_since(MONTHDAYS)
    posts
  end

  def most_liked_posts
    sql = "select guid, likes_count, interacted_at, language_id,  text from posts
    where public = true
    order by likes_count desc
    limit 50"
    ActiveRecord::Base.connection.exec_query sql
  end

  def most_liked_posts_since(last_days)
    sql = "select guid, likes_count, interacted_at, language_id, text from posts
    where public = true and created_at >= '#{Time.zone.today - last_days}'
    and likes_count > 0
    order by likes_count desc
    limit 50"
    ActiveRecord::Base.connection.exec_query sql
  end

  def most_comments_posts_since(last_days)
    sql = "select guid, comments_count, interacted_at, language_id, text from posts
    where public = true and created_at >= '#{Time.zone.today - last_days}'
    and comments_count > 0
    order by comments_count desc
    limit 50"
    ActiveRecord::Base.connection.exec_query sql
  end

  def posts_by_language
    sql = "select count(*) language_count, language_id from posts
            group by language_id
            order by language_count desc"
    ActiveRecord::Base.connection.exec_query sql
  end

  def posts_by_language_since(last_days)
    sql = "select count(*) language_count, language_id from posts
           where created_at >= '#{Time.zone.today - last_days}'
            group by language_id
            order by language_count desc
            limit 20"
    ActiveRecord::Base.connection.exec_query sql
  end

  private

  def popular_tags_since(last_days)
    ActsAsTaggableOn::Tagging.joins(:tag)
                             .limit(20)
                             .where(["taggable_type = ? and created_at >= ?
                                      and not exists (Select 1 from ignoring_tags as it where it.name = tags.name)",
                                     "Post", Time.zone.today - last_days])
                             .order(Arel.sql("count(taggings.id) DESC"))
                             .group(:tag)
                             .count
  end

  def posts_local_since(last_days)
    Post.joins(:author)
        .where(["posts.created_at >= ? and people.pod_id is null", Time.zone.today - last_days])
        .count
  end

  def posts_since(last_days)
    Post.where(["created_at >= ? ", Time.zone.today - last_days])
        .count
  end

  def comments_local_since(last_days)
    Comment.joins(:author)
           .where(["comments.created_at >= ? and people.pod_id is null", Time.zone.today - last_days])
           .count
  end

  def comments_since(last_days)
    Comment.where(["created_at >= ? ", Time.zone.today - last_days])
           .count
  end

  def users_since(last_days)
    User.where(["created_at >= ? and locked_at is null", Time.zone.today - last_days])
        .count
  end

end
