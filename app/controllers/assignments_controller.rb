class AssignmentsController < ApplicationController

  require 'chronic'

  skip_before_filter :per_page_param
  before_filter :get_context, only: [:index]

  def index
    # Options for drop-down on assignments#index
    @grading_types    = ["not_graded", "pass_fail", "percent", "letter_grade", "points"]
    @submission_types = ["none", "online_upload", "online_text_entry", "online_url"]

    # If context if given, get the assignments (only returned as json)
    assignments = @context.nil? ? { error: "Make sure courses is used in context." } : Assignment.find(:all, :params => @options)

    respond_to do |format|
      format.html
      format.json { render :json => assignments }
    end
  end

  def show
    assignment = Assignment.find(params[:id], :params => @options)

    respond_to do |format|
      format.json { render :json => assignment }
    end
  end

  def create
    iso_time = params[:overrides_added] ? nil : Chronic.parse(params[:assignment][:due_at]).utc.iso8601

    # nil out other params if grading_type is not_graded (just in case)
    if params[:assignment][:grading_type] == "not_graded"
      params[:assignment][:points_possible]   = nil
      params[:assignment][:submission_types]  = "not_graded"
    end

    # Masquerade for VDDs
    masquerade = params[:as_user_id] ? "&as_user_id=#{params[:as_user_id]}" : nil

    # ActiveResource::Base has a difficult time with the way post_fields are configured
    # Using Curl instead for POSTing an assignment
    assignment_url  = ENV["SITE_URL_CURL"] + "courses/#{params[:assignment][:course_id]}/assignments" + ENV["API_TOKEN_CURL"] + "#{masquerade}"
    assignment      = Curl::Easy.http_post(assignment_url,
      Curl::PostField.content("assignment[name]",               "#{params[:assignment][:name]}"),
      Curl::PostField.content("assignment[points_possible]",    "#{params[:assignment][:points_possible]}"),
      Curl::PostField.content("assignment[grading_type]",       "#{params[:assignment][:grading_type]}"),
      Curl::PostField.content("assignment[due_at]",             "#{iso_time}"),
      Curl::PostField.content("assignment[submission_types][]", "#{params[:assignment][:submission_types]}"),
      Curl::PostField.content("assignment[description]",        "#{params[:assignment][:description]}"))

    respond_to do |format|
      format.json { render :json => assignment.body_str }
    end
  end

end
