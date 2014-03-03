class SyncedGroupCategory < ActiveRecord::Base
  attr_protected
  has_many :synced_groups

  scope :updated_desc,  -> { order("synced_group_categories.updated_at DESC") }
  scope :deleted,       -> { where(deleted: true).order("synced_group_categories.updated_at DESC") }
  scope :active,        -> { where(deleted: false).order("synced_group_categories.updated_at DESC") }
end
