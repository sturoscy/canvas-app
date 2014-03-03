class CanvasApp.Models.Group extends Backbone.Model

  initialize: (attributes, options) ->
    @memberships = new CanvasApp.Collections.Memberships()
    if @id? then @memberships.url = "/groups/#{@id}/memberships" else false

  parse: (results) ->
    @memberships.url = "/groups/#{results.id}/memberships" unless @memberships is undefined
    results
