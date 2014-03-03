class CanvasApp.Collections.Sections extends Backbone.Collection

  initialize: (models, options) ->
    if options?
      if options.course_id?
        @course_id  = CanvasApp.course_id
        @url        = '/courses/' + @course_id + '/sections'

  model: CanvasApp.Models.Section
