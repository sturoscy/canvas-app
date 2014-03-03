class CanvasApp.Views.AssignmentImportsIndex extends Backbone.View
      
  el: "#add-assignment"

  # Templates
  errors : JST['shared/errors'] 

  events: 
    'click #add-to-table'           : 'addToQueue'
    'click #add-to-canvas'          : 'addToCanvas'
    'click #clear-assignments'      : 'clearAssignments'

  initialize: (options) ->
    @options = options || {}
    @assignment_imports = @options.assignment_imports

    @listenTo @assignment_imports, 'add', @addAssignment

    # Populate table with any locally saved data (from backbone.localStorage)
    @assignment_imports.fetch()

  addAssignment: (assignment) ->
    assignmentImportView = new CanvasApp.Views.AssignmentImportView { model: assignment }
    $("#assignments").append assignmentImportView.render().el
    @

  # Create a new Assignment model and trigger addAssignment
  addToQueue: (e) ->
    e.preventDefault

    course_id         = $("#course_id").val()
    name              = $("#name").val()
    points_possible   = $("#points_possible").val()
    grading_type      = $("#grading_type").val()
    submission_types  = $("#submission_types").val()
    wharton_west      = $("#wharton_west").is(":checked")

    nicE              = new nicEditors.findEditor("assignment_description")
    description       = nicE.getContent()

    if grading_type is "not_graded"
      submission_types = "not_graded"

    due_at = $("#due_at").val()
    @assignment_imports.create(
      {
        course_id       : course_id,
        name            : name,
        points_possible : points_possible,
        grading_type    : grading_type,
        due_at          : due_at,
        submission_types: submission_types,
        description     : description,
      }
    )
    $("div.expander").expander 
      expandPrefix: ' '
      expandText:   '[...]'

  # Add items in queue to Canvas
  addToCanvas: (e) ->
    deferred_assignments = []
    options              = {}

    @add_loading $("#assignment-action-button-group"), "Adding to Canvas"
    assignments = new CanvasApp.Collections.Assignments()

    _.each @assignment_imports.models, (assignment_import) =>
      # Delete the id attribute added by local storage or else Backbone will think this should be a PUT not POST
      delete assignment_import.attributes.id
      assignment      = new CanvasApp.Models.Assignment assignment_import.toJSON()
      assignment.url  = '/courses/' + assignment_import.attributes.course_id + '/assignments'
      assignments.add assignment
      deferred_assignments.push assignment.save { wait: true }

    Q.all(deferred_assignments)
    .then (assignment_array) =>
      @remove_loading $("#assignment-action-button-group"), 'Assignment Actions <span class="caret"></span>'
    .fail (error) =>
      throw new Error error
    .catch (e) =>
      $(".errors").html @errors { error: e.message }
    .done()

  clearAssignments: (e) ->
    e.preventDefault()
    $("#assignments tbody").empty()
    _.chain(@assignment_imports.models).clone().each (model) -> 
      model.destroy()
    @assignment_imports.reset()
