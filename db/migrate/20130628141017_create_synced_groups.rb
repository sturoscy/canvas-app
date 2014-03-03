class CreateSyncedGroups < ActiveRecord::Migration
  def up
    create_table :synced_groups do |t|
      t.integer     :group_id
      t.string      :group_name
      t.string      :section_id
      t.string      :section_name
      t.integer     :course_id
      t.string      :course_code
      t.boolean     :skip_sync
      t.references  :synced_group_category

      t.timestamps  
    end
  end

  def down
    drop_table :synced_groups
  end
end
