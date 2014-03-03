class CanvasApp.Models.GroupCategory extends Backbone.Model

  initialize: (attributes, options) ->
    @groups = new CanvasApp.Collections.Groups()
    if @id? then @groups.url = "/group_categories/#{@id}/groups" else false

  parse: (results) ->
    @groups.url = "/group_categories/#{results.id}/groups" unless @groups is undefined
    results
