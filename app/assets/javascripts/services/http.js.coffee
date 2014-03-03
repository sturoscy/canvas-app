_.extend Backbone.Events, {

  defer_fetch: (@object, @attributes) ->
    self         = @
    @attributes ?= {}

    deferred     = Q.defer()

    @object.fetch {
      data: @attributes,
      success : (object, response, options) -> deferred.resolve object
      error   : (object, xhr, options) -> deferred.reject xhr
      progress: (xhr) -> 
        percent = (xhr.loaded / xhr.total) * 100
        deferred.notify "#{Math.round percent}%"
    }

    deferred.promise

  defer_create: (@collection, @attributes) ->
    self         = @
    @attributes ?= {}

    deferred     = Q.defer()

    @collection.create @attributes,
      wait: true
      success : (model, response, options) -> deferred.resolve model
      error   : (model, xhr, options) -> deferred.reject xhr
      progress: (xhr) -> 
        percent = (xhr.loaded / xhr.total) * 100
        deferred.notify "#{Math.round percent}%"

    deferred.promise

  defer_save: (@model, @attributes) ->
    self         = @
    @attributes ?= {}

    deferred     = Q.defer()

    @model.save @attributes,
      wait: true
      success : (model, response, options) -> deferred.resolve model
      error   : (model, response, options) -> deferred.reject response 
      progress: (xhr) -> 
        percent = (xhr.loaded / xhr.total) * 100
        deferred.notify "#{Math.round percent}%"

  defer_delete: (@model, @options) ->
    self      = @
    @options ?= {}

    deferred  = Q.defer()

    @model.destroy
      wait: true
      success : (model, response, options) -> deferred.resolve model
      error   : (model, xhr, options) -> deferred.reject xhr
      progress: (xhr) -> 
        percent = (xhr.loaded / xhr.total) * 100
        deferred.notify "#{Math.round percent}%"

    deferred.promise

}
