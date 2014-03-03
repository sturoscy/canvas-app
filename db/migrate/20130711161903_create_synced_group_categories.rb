class CreateSyncedGroupCategories < ActiveRecord::Migration
  def up
    create_table :synced_group_categories do |t|
      t.integer     :group_category_id
      t.string      :group_category_name
      t.integer     :course_id
      t.string      :course_code
      t.boolean     :deleted

      t.timestamps
    end
  end

  def down
    drop_table :synced_group_categories
  end
end
