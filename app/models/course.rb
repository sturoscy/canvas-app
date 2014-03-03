class Course < ApplicationModel
  def save
    self.prefix = '/api/v1/accounts/:account_id/'
    prefix_options[:account_id] = account_id
    super
  end

end
