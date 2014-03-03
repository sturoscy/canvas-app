class CanvasApp.Views.AppointmentGroupsView extends Backbone.View
  el: "#appointment-groups"

  template: JST['appointment_groups/appointment_groups']
  errors: JST['shared/errors']

  events: 
    "click #run-ap-report": "get_appointment_groups"
    "click #clear-ap-data": "clear_appointment_groups"
    "click .print-group"  : "generate_pdf"

  initialize: (options) ->
    @options  = options || {}
    @appointment_groups = @options.appointment_groups

  get_appointment_groups: (e) ->
    e.preventDefault()

    # Params
    course_id = if $("#course_id").val() then $("#course_id").val() else $("#sis_course_id").val()
    include_past_appointments = $("#past-appointments-check").is(":checked")

    @params = {
      course_id: course_id
      include_past_appointments: include_past_appointments
    }

    @update_status "<i class='fa fa-refresh fa-spin'></i> Fetching appointment groups..."
    $(e.target).attr "disabled", "disabled"
    @defer_fetch(@appointment_groups, @params)
    .then (appointment_groups) =>
      $(".status-report").hide()
      $(e.target).removeAttr "disabled"
      $("#all-output").html @template { appointment_groups: appointment_groups.toJSON() }
    .fail (error) =>
      $(e.target).removeAttr "disabled"
      throw new Error error
    .catch (e) =>
      $(".errors").html @errors { error: e.message }
    .done()

  clear_appointment_groups: (e) ->
    $("#all-output").empty()

  generate_pdf: (e) ->
    key_to_print  = "#" + $(e.target).attr('class').split(' ')[0]
    key_to_send   = $(e.target).attr('class').split(' ')[0]
    html_snippet  = $("div" + key_to_print).html()
    course_id     = if $("#course_id").val() then $("#course_id").val() else $("#sis_course_id").val()

    pdf_appointment     = new CanvasApp.Models.AppointmentGroup()
    pdf_appointment.url = "appointment_groups/pdf"

    data = { 
      html_to_convert : html_snippet,
      key_to_print    : key_to_print,
      key_to_send     : key_to_send,
      course_id       : course_id 
    }

    $(e.target).attr "disabled", "disabled"
    @add_loading $(e.target), "Building pdf..."
    @defer_save(pdf_appointment, data)
    .then (pdf_appointment) =>
      key_to_print  = pdf_appointment["key_to_print"]
      pdf_iframe    = "<div class='span4'><iframe src='/files/#{pdf_appointment['pdf_base']}'></iframe></div>"
      $(key_to_print + "_overall").append pdf_iframe
      $(e.target).removeAttr "disabled"
      @remove_loading $(e.target), $(e.target).html()
    .fail (error) =>
      $(e.target).removeAttr "disabled"
      @remove_loading $(e.target), $(e.target).html()
      console.log error
      throw new Error error
    .done()
