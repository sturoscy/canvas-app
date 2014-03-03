_.extend Backbone.Events, {

  add_loading: (selector, text) ->
    $(selector)
      .html("<i class='fa fa-cog fa-spin'></i> " + text + "")
      .attr("disabled", "disabled")

  remove_loading: (selector, text) ->
    $(selector)
      .html(text)
      .removeAttr("disabled")

  update_progress: (selector, total_index, total_length) ->
    if total_index is 1 then $(".progress").css "display", ""
    percent = (total_index/total_length) * 100
    selector.css "width", "#{percent}%"

  update_status: (text) =>
    $(".status-report").show().html text
}
