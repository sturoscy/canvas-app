class SyncedGroup < ActiveRecord::Base
  attr_protected
  belongs_to :synced_group_category

  scope :by_group_id, -> { order("synced_groups.group_id ASC") }
end