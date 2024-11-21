# frozen_string_literal: true

class AdminsController < Admin::AdminController
  include ApplicationHelper

  def dashboard
    gon.push(pod_version: pod_version)
  end

  def user_search
    if params[:admins_controller_user_search]
      search_params = params.require(:admins_controller_user_search)
                            .permit(:username, :email, :guid, :under13)
      @search = UserSearch.new(search_params)
      @persons = @search.perform
    end

    @search ||= UserSearch.new
    @persons ||= [] # rubocop:disable Naming/MemoizedInstanceVariableName
  end

  def admin_inviter
    inviter = InvitationCode.default_inviter_or(current_user)
    email = params[:identifier]
    user = User.find_by(email: email)

    unless user
      EmailInviter.new(email, inviter).send!
      flash[:notice] = "invitation sent to #{email}"
    else
      flash[:notice]= "error sending invite to #{email}"
    end
    redirect_to user_search_path, :notice => flash[:notice]
  end

  def add_invites
    InvitationCode.find_by(token: params[:invite_code_id]).add_invites!
    redirect_to user_search_path
  end

  def weekly_user_stats
    @created_users_by_week = Hash.new{ |h,k| h[k] = [] }
    @created_users = User.where("username IS NOT NULL and created_at IS NOT NULL")
    @created_users.find_each do |u|
      week = u.created_at.beginning_of_week.strftime("%Y-%m-%d")
      @created_users_by_week[week] << {username: u.username, closed_account: u.person.closed_account}
    end

    @selected_week = params[:week] || @created_users_by_week.keys.last
    @counter = @created_users_by_week[@selected_week].count
  end

  def stats
    @stats = statistics_service.total_stat_numbers_cached
  end

  def post_stats
    @posts = statistics_service.posts_stats_cached
  end

  def tag_stats
    @popular_tags = statistics_service.popular_tags_cached
  end

  def user_stats_posts
    @most_active_users = statistics_service.most_active_users
  end

  def user_stats_comments
    @most_active_users = statistics_service.most_active_users
  end

  private

  class UserSearch
    include ActiveModel::Model
    include ActiveModel::Conversion
    include ActiveModel::Validations

    attr_accessor :username, :email, :guid, :under13

    validate :any_searchfield_present?

    def initialize(attributes={})
      assign_attributes(attributes)
      yield(self) if block_given?
    end

    def assign_attributes(values)
      values.each do |k, v|
        public_send("#{k}=", v)
      end
    end

    def any_searchfield_present?
      if %w(username email guid under13).all? { |attr| public_send(attr).blank? }
        errors.add :base, "no fields for search set"
      end
    end

    def perform
      return User.none unless valid?

      people = Person.arel_table
      users = User.arel_table
      profiles = Profile.arel_table

      persons = Person.joins("left join profiles on profiles.person_id = people.id")
                      .joins("left join users on people.owner_id = users.id")
      persons = persons.where(people[:diaspora_handle].matches("%#{username}%")) if username.present?
      persons = persons.where(users[:email].matches("%#{email}%")) if email.present?
      persons = persons.where(people[:guid].matches("%#{guid}%")) if guid.present?
      persons = persons.where(profiles[:birthday].gt(Time.zone.today - 13.years)) if under13 == "1"
      persons = persons.select("people.*, users.id as user_id, profiles.full_name as full_name,
                               (select count(*) from posts where posts.author_id = people.id) as post_count,
                               (select count(*) from comments where author_id = people.id) as comment_count")
      persons = persons.distinct
      persons.limit(50)
    end
  end

  def statistics_service
    @statistics_service ||= AdminStatisticsService.new
  end
end
