_.extend Backbone.Events, {
  
  user_search: () ->
    # Autocomplete
    self = @
    @search_count = 0
    try
      $(".sis_user_id").autocomplete {
        serviceUrl: 'user_search'
        onSearchStart: () ->
          if self.search_count is 0
            self.icon_class = $(@).parent().find(".add-on > i").attr("class")
          self.icon = $(@).parent().find(".add-on > i")
          $(self.icon).removeClass(self.icon_class).addClass("fa fa-cog fa-spin")
          self.search_count++
        formatResult: (suggestion, input_value) ->
          suggestion.data + ": " + suggestion.value
        onSearchComplete: () ->
          $(self.icon).removeClass("fa fa-cog fa-spin").addClass(self.icon_class)
        onSearchError: (query, jqXHR, textStatus, errorThrown) ->
          throw new Error errorThrown
        onSelect: (suggestion) =>
          console.log 'You selected: ' + suggestion.value + ', ' + suggestion.data
      }
    catch e
      console.log e.message

  export_groups_csv: (e) ->
    group_category_id  = +$("#group-category-dropdown").val()

    # Using jQuery's ajax for simplicity's sake
    try 
      $.ajax {
        type        : "GET",
        contentType : "application/json",
        dataType    : "json",
        url         : "/group_categories/#{group_category_id}/groups/export_csv",
        beforeSend: () =>
          @add_loading $(e.target), "Building CSV"
        ,
        success   : (response) =>
          window.open(response, "_self")
        ,
        complete  : () =>
          @remove_loading $(e.target), "Export to CSV"
        ,
        error     : (jqXHR, textStatus, errorThrown) =>
          throw new Error errorThrown
      }
    catch e
      @remove_loading $(e.target), "Export to CSV"
      $(".errors").html @errors { error: textStatus }

}
