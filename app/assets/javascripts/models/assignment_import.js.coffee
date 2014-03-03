class CanvasApp.Models.AssignmentImport extends Backbone.Model

  setAttr: (key, value, options) ->
    setter      = {}
    setter[key] = value
    @set setter, options
    @save()
    
  unsetAttr: (key, value, options) ->
    setter      = {}
    setter[key] = value
    @unset setter, options
