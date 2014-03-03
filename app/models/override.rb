class Override < ApplicationModel
  self.prefix = '/api/v1/courses/:course_id/assignments/:assignment_id/'

  def save
    prefix_options[:access_token] = ENV["API_TOKEN"]
    super
  end
end
