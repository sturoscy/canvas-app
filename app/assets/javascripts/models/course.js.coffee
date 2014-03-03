class CanvasApp.Models.Course extends Backbone.Model

  initialize: (attributes, options) ->
    if @id?
      CanvasApp.course_id = @id
      @assignments        = new CanvasApp.Collections.Assignments     [], { course_id: @id }
      @group_categories   = new CanvasApp.Collections.GroupCategories [], { course_id: @id }
      @groups             = new CanvasApp.Collections.Groups          [], { course_id: @id }
      @sections           = new CanvasApp.Collections.Sections        [], { course_id: @id }

  urlRoot: "/courses"
