class CanvasApp.Collections.Overrides extends Backbone.Collection

  initialize: (models, options) ->
    if options?
      if options.course_id? && options.assignment_id?
        @course_id      = options.course_id
        @assignment_id  = options.assignment_id
        @url = '/courses/' + @course_id + '/assignments/' + @assignment_id + '/overrides'

  model: CanvasApp.Models.Override