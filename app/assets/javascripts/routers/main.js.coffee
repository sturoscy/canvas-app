class CanvasApp.Routers.Main extends Backbone.Router

  initialize: (options) ->
    Backbone.Events.user_search()

    # Hide status initially
    $(".status-report").hide()

  routes: 
    'appointment_groups'      : 'appointment_groups',
    'assignments'             : 'assignments',
    'synced_group_categories' : 'synced_group_categories',

  appointment_groups: () ->
    new CanvasApp.Views.AppointmentGroupsView { appointment_groups: new CanvasApp.Collections.AppointmentGroups() }
    $(".course-id-tool").tooltip
      title: "This is the Course ID from a Canvas Course URL"
    $(".sis-course-id-tool").tooltip
      title: "This is the SIS ID entered during course creation (ACCT101)"
    $(".user-id-tool").tooltip
      title: "Start typing a user's name to search for their SIS User ID"

  assignments: () ->
    # ToolTips
    $("body").popover {
      container : 'body'
      html      : true
      placement : 'top'
      selector  : '[rel="popover"]'
      title     : 'Varied Due Dates'
      trigger   : 'hover'
    }

    new CanvasApp.Views.AssignmentImportsIndex { assignment_imports: new CanvasApp.Collections.AssignmentImports() }

    # Load WYSIWYG Editor
    bkLib.onDomLoaded ->
      new nicEditor().panelInstance("assignment_description")

  synced_group_categories: () ->
    new CanvasApp.Views.SyncedGroupCategoriesAutoSync   { 
      synced_group_categories: window.synced_group_categories, 
      synced_groups: window.synced_groups 
    }
    new CanvasApp.Views.SyncedGroupCategoriesManualSync { 
      synced_group_categories: window.synced_group_categories, 
      synced_groups: window.synced_groups 
    }

    # Show/Hide Instructions
    $(".sync-help").click (e) =>
      $("#sync-instructions").toggle()

    $(document).bind "bootstrap_select", (e) =>
      $(".selectpicker").selectpicker()
      