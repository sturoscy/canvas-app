class CanvasApp.Views.SyncedGroupCategoriesManualSync extends Backbone.View
  el: '#section-groups'

  # Local Synced Group Categories and Groups
  template: JST['synced_group_categories/synced_group_category']
  errors  : JST['shared/errors']

  # Canvas Group Categories and Groups
  group_category_dropdown : JST['group_categories/group_category_dropdown']
  groups_sections         : JST['groups/groups_sections']

  events: 
    'click .start-manual-sync'        : 'get_group_categories'
    'change #group-category-dropdown' : 'get_groups'
    'click .finish-manual-sync'       : 'finish_manual_sync'
    'click .export-csv'               : 'export_csv'

  initialize: (options) ->
    @options  = options || {}

    # Bootstrapped collections (from synced_group_categories/index.html.erb)
    # Passed into view from router and available via @options
    @synced_group_categories  = @options.synced_group_categories
    @synced_groups            = @options.synced_groups

  get_group_categories: (e) ->
    @button     = e.target
    @course_id  = $("#course_id").val()

    @course           = new CanvasApp.Models.Course { id: @course_id }
    group_categories  = @defer_fetch @course.group_categories
    
    @add_loading $(@button), "Getting Categories..."
    if !!@course_id
      group_categories
      .then (group_categories) =>
        @remove_loading $(@button), "Manual Sync"
        $("#group-category-placeholder").html @group_category_dropdown categories: group_categories.toJSON(), course_id: @course_id
      .fail (error) => 
        error_message = if (!!error.responseJSON and error.responseJSON.status is "not_found") then "Resource not found. Please check course ID." else "There was an error with your last request. #{error.statusText}"
        throw new Error error_message
      .catch (e) => 
        @remove_loading $(@button), "Manual Sync"
        $(".errors").html @errors { error: e.message }
      .done()
    else
      @remove_loading $(@button), "Manual Sync"
      $(".errors").html @errors { error: "Please enter a course ID" }

  get_groups: (e) ->
    group_category_id = $(e.target).val()
    @group_category   = @course.group_categories.findWhere { id: +group_category_id }
    sections          = @defer_fetch @course.sections

    @add_loading ".group-category-dropdown-load", "Getting Groups..."
    sections
    .then (sections) => 
      @defer_fetch(@group_category.groups)
      .then (groups) =>
        # Catch empty group set
        if groups.length is 0 then throw new Error error_message = "There aren't any groups for group set: #{group_category_id}"

        @remove_loading ".group-category-dropdown-load", ""
        $("#manual-groups-sections")
          .html(@groups_sections groups: groups.toJSON(), sections: sections.toJSON())
          .pajinate {
            num_page_links_to_display: 7,
            wrap_around: true
          }
        $(".selectpicker").trigger "bootstrap_select"        
    .fail (error) =>
      throw new Error error
    .catch (e) =>
      @remove_loading ".group-category-dropdown-load", ""
      $(".errors").html @errors { error: e.message }
    .done()

  finish_manual_sync: (e) ->
    group_category_id = $("#group-category-dropdown").val()
    synced_group_category_check = @synced_group_categories.findWhere { group_category_id: +group_category_id }
    if synced_group_category_check?
      user_check = confirm "Group Category has been synced. Update?"
      if user_check then @update(synced_group_category_check, e) else return false
    else
      @create e

  create: (e) ->
    group_category_id   = +$("#group-category-dropdown").val()
    sections_for_group  = {}

    # Build Sections to Groups object
    $(".groups-sections").each (index, element) =>
      sections_for_group[$(element).attr("id")] = $(element).children().find("select").val()

    # Create local synced group category
    synced_group_category_attributes = {
      group_category_id   : @group_category.attributes.id,
      group_category_name : @group_category.attributes.name,
      course_id           : @course.id,
      course_code         : @course.attributes.course_code,
      deleted             : false
    }
    synced_group_category = @defer_create(@synced_group_categories, synced_group_category_attributes)

    $(e.target).attr "disabled", "disabled"

    # Resolve synced group category promise
    synced_group_category
    .then (synced_group_category) =>
      total_index   = 0
      total_length  = 0
      _.each sections_for_group, (section_ids, group_id) =>
        group = @group_category.groups.findWhere { id: +group_id }
        @update_status "Found group: #{group.attributes.id}"
        _.each section_ids, (section_id, section_index) =>
          section = @course.sections.findWhere { id: +section_id }
          total_length += section.attributes.students.length

          # Create local synced group
          synced_group_attributes = {
            group_id    : group.attributes.id,
            group_name  : group.attributes.name,
            section_id  : section.attributes.id,
            section_name: section.attributes.name,
            course_id   : @course.attributes.id,
            course_code : @course.attributes.course_code,
            skip_sync   : false,
            synced_group_category_id: synced_group_category.attributes.id,
          }
          @defer_create(synced_group_category.synced_groups, synced_group_attributes)

          # Resolve synced group promise each in turn and create memberships for Canvas group
          .then (synced_group) =>
            synced_group
          , (error) => throw new Error error
          _.each section.attributes.students, (student, student_index) =>
            @defer_create(group.memberships, { user_id: student.id })
            .then (membership) =>
              @update_status "Creating membership: #{membership.attributes.id}"
              @update_progress $(".bar"), total_index += 1, total_length
              if total_index is total_length
                @update_status "All done. About to reload page."
                location.reload()
            , (error) => throw new Error error
    .fail (error) =>
      throw new Error error
    .catch (e) =>
      $(".status").hide()
      $(e.target).removeAttr "disabled"
      $(".errors").html @errors { error: e.message }
    .done()

  update: (synced_group_category, e) ->
    # The update method is nearly identical to create (except for the synced groups defer delete)
    # Need to refactor this method so as not to violate DRY principle
    deferred_delete     = []
    @group_category_id  = $("#group-category-dropdown").val()
    sections_for_group  = {}

    # For progress bar
    total_index   = 0
    total_length  = 0

    # Build Sections to Groups object
    $(".groups-sections").each (index, element) =>
      sections_for_group[$(element).attr("id")] = $(element).children().find("select").val()

    # Delete and remove each synced group
    # Simpler to delete then recreate synced groups rather than PUT (update)
    synced_group_category.save { patch: true }
    _.each synced_group_category.synced_groups.models, (synced_group, index) =>
      deferred_delete.push(@defer_delete(synced_group))

    $(e.target).attr "disabled", "disabled"

    # Resolve deletes
    Q.all(deferred_delete)
    .then (synced_groups) =>
      _.each synced_groups, (synced_group, index) =>
        @synced_groups.remove synced_group
      _.each sections_for_group, (section_ids, group_id) =>
        group = @group_category.groups.findWhere { id: +group_id }
        @update_status "Found group: #{group.attributes.id}"
        _.each section_ids, (section_id, index) =>
          section = @course.sections.findWhere { id: +section_id }
          total_length += section.attributes.students.length

          # Recreate local synced group
          synced_group_attributes = {
            group_id    : group.attributes.id,
            group_name  : group.attributes.name,
            section_id  : section.attributes.id,
            section_name: section.attributes.name,
            course_id   : @course.attributes.id,
            course_code : @course.attributes.course_code,
            skip_sync   : false,
            synced_group_category_id: synced_group_category.attributes.id
          }
          @defer_create(synced_group_category.synced_groups, synced_group_attributes)

          # Resolve synced group promise each in turn and create memberships for Canvas group
          .then (synced_group) =>
            synced_group
          , (error) =>
            throw new Error error
          _.each section.attributes.students, (student, student_index) =>
            @defer_create(group.memberships, { user_id: student.id })
            .then (membership) =>
              @update_status "Creating membership: #{membership.attributes.id}"
              @update_progress $(".bar"), total_index += 1, total_length
              if total_index is total_length
                @update_status "All done. About to reload page."
                location.reload()
            , (error) => throw new Error error
    .fail (error) =>
      throw new Error error
    .catch (e) =>
      $(".status").hide()
      $(e.target).removeAttr "disabled"
      $(".errors").html @errors { error: e.message }
    .done()

  export_csv: (e) ->
    group_category_id  = +$("#group-category-dropdown").val()

    # Using jQuery's $.ajax (Does not really fit in with Backbone's Model/Collection)
    try 
      $.ajax {
        type        : "GET",
        contentType : "application/json",
        dataType    : "json",
        url         : "/group_categories/#{group_category_id}/groups/export_csv",
        beforeSend: () =>
          @add_loading $(e.target), "Building CSV"
        success   : (response) =>
          window.open(response, "_self")
        complete  : () =>
          @remove_loading $(e.target), "Export to CSV"
        error     : (jqXHR, textStatus, errorThrown) ->
          throw new Error errorThrown
        progress  : (jqXHR) ->
          percent = (jqXHR.loaded / jqXHR.total) * 100
          console.log "#{Math.round percent}%"
      }
    catch e
      @remove_loading $(e.target), "Export to CSV"
      $(".errors").html @errors { error: textStatus }
