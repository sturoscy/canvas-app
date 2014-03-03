# Load the rails application
require File.expand_path('../application', __FILE__)

ActiveResource::Base.logger = ActionController::Base.logger

# Initialize the rails application
CanvasApp::Application.initialize!
