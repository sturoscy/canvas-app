class ApplicationModel < ActiveResource::Base
  self.site     = ENV["SITE_URL"]
  self.prefix   = '/api/v1/'
end
