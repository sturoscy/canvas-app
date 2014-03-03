class OverridesController < ApplicationController

  require 'chronic'

  def index
    overrides = Override.find(:all, :params => @options)

    respond_to do |format|
      format.json { render :json => overrides }
    end
  end

  def show
    override = Override.find(params[:id], :params => @options)

    respond_to do |format|
      format.json { render :json => override }
    end
  end

  def create
    iso_time = Chronic.parse(params[:START_TIME]).utc.iso8601

    # Masquerade for VDDs
    masquerade = params[:as_user_id] ? "&as_user_id=#{params[:as_user_id]}" : nil

    # ActiveResource::Base has a difficult time with the way post_fields are configured
    # Using Curl instead for POSTing an assignment
    override_url  = ENV["SITE_URL_CURL"] + "courses/#{params[:course_id]}/assignments/#{params[:assignment_id]}/overrides" + ENV["API_TOKEN_CURL"] + "#{masquerade}"
    override      = Curl::Easy.http_post(override_url,
      Curl::PostField.content("assignment_override[course_section_id]",  "#{params[:SECTION_ID]}"),
      Curl::PostField.content("assignment_override[due_at]",             "#{iso_time}"))

    respond_to do |format|
      format.json { render :json => override.body_str }
    end 
  end

  def destroy
    override = Override.find(params[:id], :params => { :course_id => params[:course_id], :assignment_id => params[:assignment_id], :access_token => ENV["API_TOKEN"] })

    respond_to do |format|
      format.json { render :json => "Varied Due Date Deleted" }
    end
  end
end