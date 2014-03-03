class CanvasApp.Collections.Groups extends Backbone.Collection

  initialize: (models, options) ->
    if options?
      if options.course_id?
        @course_id  = if CanvasApp.course_id? then CanvasApp.course_id else options.course_id
        @url        = "/courses/#{@course_id}/groups"
      else if options.group_category_id?
        @group_category_id  = options.group_category_id
        @url                =  "/group_categories/#{@group_category_id}/groups"

  model: CanvasApp.Models.Group
  