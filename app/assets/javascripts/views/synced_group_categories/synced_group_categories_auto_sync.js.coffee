class CanvasApp.Views.SyncedGroupCategoriesAutoSync extends Backbone.View

  el: '#section-groups'

  # Local Synced Group Categories and Groups
  template: JST['synced_group_categories/synced_group_category']
  gc_row  : JST['synced_group_categories/synced_group_category_row']
  gp_row  : JST['synced_groups/synced_group_row']
  errors  : JST['shared/errors']

  events: 
    'click #sync-section-groups'  : 'start_full_sync'
    'click .clear-section-groups' : 'delete'

  initialize: (options) ->
    @options  = options || {}

    # Bootstrapped collections (from synced_group_categories/index.html.erb)
    # Passed into view from router and available via @options
    @synced_group_categories  = @options.synced_group_categories
    @synced_groups            = @options.synced_groups

  start_full_sync: (e) ->
    @course_id = +$("#course_id").val()
    @course    = new CanvasApp.Models.Course { id: @course_id }

    $(e.target).attr "disabled", "disabled"
    @update_status "<strong>Beginning Sync</strong>"
    if !!@course_id
      @defer_fetch(@course)
      .then (course) =>
        @update_status "Found Course"
        synced_group_categories_check = @synced_group_categories.where { course_id: @course_id }
        if synced_group_categories_check.length
          _.each synced_group_categories_check, (synced_group_category_check, index) =>
            if synced_group_category_check.attributes.group_category_name is "Groups for Sections"
              if synced_group_category_check.attributes.deleted is true
                user_check = confirm("This course had a previous sync, but was deleted. Re-sync?")
                @create(@course_id) unless !user_check
              else
                error = "Category (ID: " + synced_group_category_check.attributes.group_category_id + ") has already been synced to course."
                throw new Error error
            else
              @create(@course_id)
        else
          @create(@course_id)
      .fail (error) =>
        status  = if error.statusText then error.statusText else error
        error   = if (!!error.responseJSON and error.responseJSON.status is "not_found") then "Resource not found. Please check course ID." else "There was an error with your last request. #{status}"
        throw new Error error
      .catch (e) =>
        $(e.target).removeAttr "disabled"
        $(".status").hide()
        $(".errors").html @errors { error: e.message }
      .done()
    else
      $(e.target).removeAttr "disabled"
      error = { error: "Please input a Course ID.", comment: "Course ID is blank" }
      $(".errors").html @errors error

  create: (course_id) ->
    @sections       = @defer_fetch @course.sections
    @group_category = @defer_create @course.group_categories, { name: "Groups for Sections" }

    Q.all([@sections, @group_category])
    .spread (sections, group_category) =>
      @update_status "Creating Group Set"
      # Resolve sections and group_category promises from above and create local synced_group_category
      synced_group_category_attributes = {
        group_category_id   : group_category.attributes.id, 
        group_category_name : group_category.attributes.name,
        course_id           : @course.attributes.id,
        course_code         : @course.attributes.course_code,
        deleted             : false
      }
      @synced_group_category = @synced_group_categories.create synced_group_category_attributes
      groups    = []
      students  = []
      _.each sections.models, (section, index) =>
        groups[index]   = @defer_create(group_category.groups, { name: section.attributes.name })
        students[index] = section.attributes.students
      [groups, students]
    .spread (groups, students_array) =>
      # Create groups and memberships

      # Initialize progress bar
      flattened_students  = _.flatten students_array
      total_index         = 0 
      total_length        = (groups.length) + (flattened_students.length)

      _.each students_array, (students, index) =>
        groups[index]
        .then (group) =>
          @update_status "Creating Group: #{group.attributes.id}"
          # Resolve each group promise and create synced_group
          synced_group_attributes = {
            group_id    : group.attributes.id,
            group_name  : group.attributes.name,
            section_id  : @course.sections.models[index].attributes.id,
            section_name: @course.sections.models[index].attributes.name,
            course_id   : @course.attributes.id,
            course_code : @course.attributes.course_code,
            skip_sync   : false,
            synced_group_category_id: @synced_group_category.attributes.id
          }
          @defer_create(@synced_group_category.synced_groups, synced_group_attributes)

          # Update progress bar on group create
          @update_progress $(".bar"), total_index += 1, total_length
          _.each students, (student) =>
            # Create group membership
            @defer_create(group.memberships, { user_id: student.id })
            .then (membership) => 
              @update_status "Creating membership: #{membership.attributes.id}"
              @update_progress $(".bar"), total_index += 1, total_length
              # Reload current page on finish
              if total_index is total_length 
                @update_status "All done. About to reload page..."
                location.reload()
            , (error) =>
              throw new Error error
        , (error) => throw new Error error
    .fail (error) ->
      error = if error.responseJSON? then error.responseJSON.errors.name[0].message else error
      throw new Error error
    .catch (e) =>
      $(e.target).attr "disabled", ""
      $(".errors").html @errors { error: e.message }
    .done()

  delete: (e) ->
    group_category_id = +$(e.target).parents("tr").data("groupcategoryid")

    user_check = confirm "Are you sure you want to remove the sync? NOTE: This will not remove the group category in Canvas."
    if user_check is true
      @add_loading($(e.target).parents("tr").children("td.status"), "<b>deleting</b>")
      synced_group_category_remove  = @synced_group_categories.findWhere({ group_category_id: group_category_id })
      synced_group_category_remove  = @synced_group_categories.findWhere({ group_category_id: group_category_id })
      synced_groups_remove          = synced_group_category_remove.synced_groups.toArray()

      data_remove = [synced_group_category_remove]
      data_remove = data_remove.concat synced_groups_remove
      data_remove - _.map(data_remove, (data) => data.destroy())
      Q.allSettled(data_remove)
      .then () =>
        @remove_loading($(e.target).parents("tr").children("td.status"), "<span class='label label-important'>deleted</span>")
      .fail (error) =>
        throw new Error error
      .catch (e) =>
        $(".errors").html @errors { error: e.message }
      .done()
    else
      return false
