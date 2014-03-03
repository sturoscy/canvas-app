module SyncGroups

  def self.sync_log
    @@sync_log ||= Logger.new("#{Rails.root}/log/group_sync.log")
  end

  def self.check_paging(memberships, group)
    unless memberships.empty?
      @page += 1
      memberships = group.get(:memberships, :page => @page, :per_page => 100, :access_token => ENV["API_TOKEN"])
      @membership_array << memberships
      self.check_paging(memberships, group)
    else
      @membership_array.flatten!
      @membership_hash[group.id] = @membership_array
    end
  end

  def self.check_category(synced_categories)
    synced_categories.each do |synced_category|
      if group_category = GroupCategory.find(synced_category.group_category_id, :params => { :access_token => ENV["API_TOKEN"] })
        if group_category.name != synced_category.group_category_name
          self.sync_log.info "Group Category Name - #{synced_category.group_category_name} - has changed in Canvas"
          self.sync_log.info "Updating..."
          synced_category.group_category_name = group_category.name
          synced_category.touch
          synced_category.save
          self.sync_log.info "Done!"
        end
      else
        self.sync_log.info "Group Category ID - #{synced_category.group_category_id} - has been deleted from Canvas"
        self.sync_log.info "Deleting..."
        synced_category.delete
        self.sync_log.info "Done!"
      end
    end
  end

  def self.check_group(synced_categories)
    synced_categories.each do |synced_category|
      group_category  = GroupCategory.find(synced_category.group_category_id, :params => { :access_token => ENV["API_TOKEN"] })
      groups          = group_category.get(:groups, :per_page => 50, :access_token => ENV["API_TOKEN"] )
      
      # Get unique values from synced_groups
      synced_groups = synced_category.synced_groups.group(:group_id).order(group_id: :desc)

      # Compare
      if groups.length == synced_groups.length
        groups.each_with_index do |group, index|
          if synced_groups[index].group_name != group['name']
            self.sync_log.info "The name has changed for Group - #{group['name']} - with ID - #{group['id']}"
            self.sync_log.info "Updating..."

            # Update ALL synced_groups with given group_id
            SyncedGroup.where("group_id = ?", group['id']).update_all(:group_name => group['name'], :updated_at => Time.now())
            self.sync_log.info "Done!"
          end
        end
      elsif groups.length < synced_groups.length
        self.sync_log.info "A Group has been deleted from #{synced_category.group_category_name}"
        # Find which group has been deleted
        synced_groups.each do |synced_group|

          if groups.detect { |group| group['id'] == synced_group.group_id }.nil?
            self.sync_log.info "Group ID - #{synced_group.group_id} - has been deleted from Canvas"
            self.sync_log.info "Updating..."
            synced_category.synced_groups.where("group_id = ?", synced_group.group_id).destroy_all
            self.sync_log.info "Done!"
          else
            self.sync_log.info "Group ID - #{synced_group.group_id} - is still in Canvas"
          end

        end
      else
        # Possibly check for empty group or a group added later after initial sync
      end
    end
  end

  def self.check_membership(synced_categories)
    # Student and Membership Hashes
    @student_hash     = Hash.new { |hash, key| hash[key] = Array.new }
    @membership_hash  = {}

    synced_categories.each do |synced_category|
      group_category = GroupCategory.find(synced_category.group_category_id, :params => { :access_token => ENV["API_TOKEN"] })
      groups_context = group_category.get(:groups, :per_page => 50, :access_token => ENV["API_TOKEN"])

      course    = Course.find(synced_category.course_id, :params => { :access_token => ENV["API_TOKEN"] })
      sections  = course.get(:sections, :include => ["students"], :access_token => ENV["API_TOKEN"])

      groups_context.each_with_index do |group, index|
        group_model       = Group.find(group['id'], :params => { :access_token => ENV["API_TOKEN"] })
        @membership_array = []

        @page       = 1
        memberships = group_model.get(:memberships, :page => @page, :per_page => 100, :access_token => ENV["API_TOKEN"])
        @membership_array << memberships
        self.check_paging(memberships, group_model)
      end

      # Get all synced_groups in category
      synced_groups = synced_category.synced_groups
      synced_groups.each do |synced_group|
        section = sections.detect { |section| section['id'] == synced_group.section_id }
        @student_hash[synced_group.group_id] << section['students']
      end
    end

    @student_hash.each do |group_id, students|
      students.flatten!
      group = Group.find(group_id, :params => { :access_token => ENV["API_TOKEN"] })
      unless @membership_hash[group_id].empty?
        student_ids = students.map{ |student| student['id'] }
        assigned    = students.map{ |student| student['id'] } & @membership_hash[group_id].map { |membership| membership['user_id'] }
        unassigned  = student_ids - assigned
      end
      unless unassigned.empty?
        unassigned.each do |id|
          self.sync_log.info "Student with ID - #{id} - is either unassigned or in the wrong group."
          self.sync_log.info "Fixing membership..."
          group.post(:memberships, :user_id => id, :access_token => ENV["API_TOKEN"])
          self.sync_log.info "Done!"
        end
      end
    end
  end

  def self.sync
    self.sync_log.info "\n\n### Sync check performed on #{Time.now.strftime('%m-%d-%Y %l:%M:%S %p')} ###"
    synced_categories = SyncedGroupCategory.all
    synced_groups     = SyncedGroup.all

    # Check for Category Existence in Canvas
    self.check_category(synced_categories)

    # Check for Group Existence in Canvas
    self.check_group(synced_categories)

    # Check for Membership Existence
    self.check_membership(synced_categories)
    self.sync_log.info "\n### Sync check done. ###"
  end
end
