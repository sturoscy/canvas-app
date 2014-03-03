module GroupsHelper

  def root_account
    account       = Account.find(:first, :params => { :access_token => ENV["API_TOKEN"] })
    root_account  = account.root_account_id.nil? ? account.id : nil
  end

  def perform_export(export_data=[])
    export_data ||= []
    groups, memberships = export_data

    export_file   = "groups_export_#{Time.now().strftime('%m-%d-%Y-%H%M%S')}.csv"
    @download_url = root_url + export_file

    CSV.open(Rails.root.join("public", export_file), "wb") do |csv|
      csv << ["Group Name", "Group ID", "User ID", "User Login", "User Full Name"]
      groups.each do |group|
        if memberships[group['id']].empty?
          csv << ["#{group['name']}", "#{group['id']}"]
        else
          memberships[group['id']].each do |member|
            profile_url = ENV["SITE_URL_CURL"] + "accounts/#{root_account}/users" + ENV["API_TOKEN_CURL"] + "&search_term=#{member['user_id']}"
            profile     = Curl::Easy.perform(profile_url)
            profile_results = JSON.parse(profile.body_str)
            csv << ["#{group['name']}", "#{group['id']}", "#{profile_results[0]['id']}", "#{profile_results[0]['login_id']}", "#{profile_results[0]['sortable_name']}"]
          end
        end
      end
    end 
  end

end