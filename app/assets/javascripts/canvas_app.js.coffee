#= require_self
#= require_tree ../templates
#= require_tree ./models
#= require_tree ./collections
#= require_tree ./views
#= require_tree ./services
#= require_tree ./routers

window.CanvasApp =
  Models      : {}
  Collections : {}
  Views       : {}
  Routers     : {}

  initialize: -> 
    _.extend Backbone.View.prototype, Backbone.Events
    _.extend Backbone.Router.prototype, Backbone.Events

    new CanvasApp.Routers.Main()
    Backbone.history.start { pushState: true }

$(document).ready ->
  CanvasApp.initialize()
