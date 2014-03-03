class CanvasApp.Collections.AssignmentImports extends Backbone.Collection
  
  model: CanvasApp.Models.AssignmentImport

  localStorage: new Backbone.LocalStorage("AssignmentImports")
