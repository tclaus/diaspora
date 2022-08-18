namespace :diaspora do
  desc "Force initial fetch of users"
  task  fetch_for_all_users: :environment do
    reset_people_to_initial_status
    refetch_people
  end

  desc "Fetch all public posts from all diaspora pods" do
    task fetch_public_posts_from_pods: :environment do

    end
  end

  def reset_people_to_initial_status
    people_done = Person.where(fetch_status: Diaspora::Fetcher::Public::Status_Done)
    people_done.update_all(fetch_status: Diaspora::Fetcher::Public::Status_Initial)
  end

  def refetch_people
    initial_state_people = Person.where(fetch_status: Diaspora::Fetcher::Public::Status_Initial)
    puts "Fetch for #{initial_state_people.count} persons"
    initial_state_people.find_each do |person|
      queue_for_fetching(person)
    end
  end


  def queue_for_fetching(person)
    return if person.closed_account?
    return if person.pod.status == 1 # No Error

    Diaspora::Fetcher::Public.queue_for(person)
  rescue => e
    puts "Error on #{person.diaspora_handle} with: #{e}"
  end
end
