class CanvasApp.Models.SyncedGroupCategory extends Backbone.Model
 
  initialize: (attributes, options) ->
    @synced_groups = new CanvasApp.Collections.SyncedGroups()
    if @id? then @synced_groups.url = "/synced_group_categories/#{@id}/synced_groups" else false

  parse: (results) ->
    @synced_groups.url = "/synced_group_categories/#{results.id}/synced_groups" unless @synced_groups is undefined
    results
