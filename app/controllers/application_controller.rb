class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :check_masquerade

  before_filter :per_page_param, :only => [:index]
  
  before_filter :build_params

  after_filter  :pretty_results, :only => [:index, :show]

  include ApplicationHelper

  # Exception Handlers
  # ActiveRecord
  rescue_from ActiveRecord::RecordNotFound,     with: :record_not_found

  # ActiveResource
  rescue_from ActiveResource::BadRequest,       with: :bad_request
  rescue_from ActiveResource::ResourceNotFound, with: :record_not_found
  rescue_from ActiveResource::ServerError,      with: :server_error

  def check_masquerade
    if session[:masquerade_as]
      params[:as_user_id] = "sis_user_id:#{session[:masquerade_as]}"
    end
  end

  def per_page_param
    params[:page]     = 1 if params[:page].nil?
    params[:per_page] = 10 if params[:per_page].nil?
    @page     = params[:page] ? params[:page] : 1
    @per_page = params[:per_page] ? params[:per_page] : 10
  end

  def build_params
    @options = {}
    params.each do |key, value|
      unless key == 'action' || key == 'controller' || key == 'format'
        @options[key.to_sym] = value
      end
    end
    @options[:access_token] = ENV["API_TOKEN"]
    @options
  end

  def get_context
    unless @context
      if params[:account_id]
        @context = Account.find(params[:account_id], :params => @options)
      elsif params[:appointment_group_id]
        @context = AppointmentGroup.find(params[:appointment_group_id], :params => @options)
      elsif params[:course_id]
        @context = Course.find(params[:course_id], :params => @options)
      elsif params[:group_category_id]
        @context = GroupCategory.find(params[:group_category_id], :params => @options)
      elsif params[:group_id]
        @context = Group.find(params[:group_id], :params => @options)
      elsif params[:synced_group_category_id]
        @context = SyncedGroupCategory.find(params[:synced_group_category_id])
      else
        return false
      end
    end
  end

  def pretty_results
    response.body = response.content_type == "application/json" ? JSON.pretty_generate(MultiJson.load(response.body)) : response.body
  end

  def root_account
    account       = Account.find(:first, :params => { :access_token => ENV["API_TOKEN"] })
    root_account  = account.root_account_id.nil? ? account.id : nil
  end

  def user_search
    username      = URI.escape(params[:query])
    # Perform Search (cURL) from Autocomplete Query Param
    # cURL seems to perform better here instead of ActiveResource
    search_url    = ENV["SITE_URL_CURL"] + "accounts/#{root_account}/users" + ENV["API_TOKEN_CURL"] + "&search_term=#{username}&per_page=50"
    search_get    = Curl::Easy.perform(search_url)
    search_result = JSON.parse(search_get.body_str)

    # Map Search Results to Autocomplete Friendly Hash Object
    search_result.map! { |user| { value: user["sis_user_id"], data: user["name"] } }
    query = { suggestions: search_result }

    respond_to do |format|
      format.json { render :json => query }
    end
  end

  # Exception handlers
  def bad_request(exception)
    logger.info "#{Time.now} - Exception: #{exception}"
    render :json => exception.response.body, :status => 400
  end

  def record_not_found(exception)
    logger.info "#{Time.now} - Exception: #{exception}"
    render :json => exception.response.body, :status => 404
  end

  def server_error(exception)
    logger.info "#{Time.now} - Exception: #{exception}"
    render :json => "#{exception}", :status => 500
  end
end
