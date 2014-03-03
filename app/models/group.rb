class Group < ApplicationModel
  def save
    self.site = '/api/v1/group_categories/:group_category_id/'

    prefix_options[:group_category_id]  = group_category_id
    prefix_options[:access_token]       = ENV["API_TOKEN"]
    super
  end
end
