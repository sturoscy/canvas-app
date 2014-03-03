require 'rake'

namespace :canvas_tasks do
  desc "Sync groups from sections"
  task :sync_groups => :environment do
    SyncGroups.sync
  end
end
