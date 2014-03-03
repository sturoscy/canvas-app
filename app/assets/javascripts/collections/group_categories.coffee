class CanvasApp.Collections.GroupCategories extends Backbone.Collection

  initialize: (models, options) ->
    if options?
      if options.course_id?
        @course_id  = if CanvasApp.course_id? then CanvasApp.course_id else options.course_id
        @url        = '/courses/' + @course_id + '/group_categories'
    else
      @url = '/group_categories'
  
  model: CanvasApp.Models.GroupCategory
  