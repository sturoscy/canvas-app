_.extend Backbone.Events, {
  
  format_date: (date) ->
    d = new Date(date)
    d.toLocaleDateString() + ' ' + d.toLocaleTimeString()

}