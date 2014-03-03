class CanvasApp.Models.Account extends Backbone.Model

  initialize: (options) ->
    if @id?
      @courses  = new CanvasApp.Collections.Courses({ account_id: @id })
  