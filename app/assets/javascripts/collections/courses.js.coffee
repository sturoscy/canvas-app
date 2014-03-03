class CanvasApp.Collections.Courses extends Backbone.Collection

  initialize: (models, options) ->
    if options?
      if options.account_id?
        @account_id = options.account_id
        @url = '/accounts/' + @account_id + '/courses'
      else
        @url = '/courses'

  model: CanvasApp.Models.Course
