class CanvasApp.Collections.Memberships extends Backbone.Collection

  initialize: (models, options) ->
    if options?
      if options.group_id?
        @group_id = options.group_id
        @url      = "/groups/#{@group_id}/memberships"

  model: CanvasApp.Models.Membership
