class CanvasApp.Views.AssignmentImportView extends Backbone.View

  tagName: "tr"

  template: JST['assignment_imports/assignment_import']

  events: 
    'dblclick div'    : 'edit' 
    'click #delete'   : 'clear'
    'keypress .edit'  : 'updateOnEnter'
    'blur .edit'      : 'close'

  initialize: ->
    _.bindAll @

    @listenTo @model, 'change',   @render
    @listenTo @model, 'destroy',  @remove

  render: ->
    $(@el).html @template @model.toJSON()
    @

  edit: (e) ->
    # Get parent td from clicked div
    @td = $(e.currentTarget).parent()

    # Get input from td children
    @input = @td.children '.edit'

    # Add the editing class
    @td.addClass 'editing'

    # Focus on input
    @input.focus() 

  close: (e) ->

    # New value from editing
    value = @input.val()

    # Course attribute to update
    assignment_attr = @td.attr('id')

    if value
      @model.setAttr(assignment_attr, value)
    else
      @model.unsetAttr(assignment_attr)

    # Remove the editing class when finished
    @td.removeClass 'editing'

    # Expander (to truncate assignment description for easier reading)
    # Unobtrusive to actual description value
    $("div.expander").expander
      expandPrefix:  ' '
      expandText:   '[...]'

  updateOnEnter: (e) ->
    # On enter, we are done editing
    if e.which is 13
      @close()

  clear: (e) ->
    # Get rid of the model when Delete is clicked
    @model.destroy()

    @stopListening(@model)

    delete @.$el
    delete @.el