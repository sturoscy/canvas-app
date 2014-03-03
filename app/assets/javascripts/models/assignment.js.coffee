class CanvasApp.Models.Assignment extends Backbone.Model

  initialize: (attributes, options) ->
    @overrides = new CanvasApp.Collections.Overrides()
    if @id? then @overrides.url = "/courses/#{CanvasApp.course_id}/assignments/#{@id}/overrides" else false

  parse: (results) ->
    @overrides.url = "/courses/#{results.course_id}/assignments/#{results.id}/overrides" unless @assignments is undefined
    results
