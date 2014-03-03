class CanvasApp.Collections.Assignments extends Backbone.Collection

  initialize: (models, options) ->
    if options?
      if options.course_id?
        @course_id  = if CanvasApp.course_id? then CanvasApp.course_id else options.course_id
        @url        = '/courses/' + @course_id + '/assignments'
    else
      @url = '/assignments'

  model: CanvasApp.Models.Assignment
