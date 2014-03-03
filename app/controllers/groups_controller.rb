class GroupsController < ApplicationController
 
  skip_before_filter :per_page_param, :only => [:index, :export_csv]
  before_filter :get_context, :only => [:index, :create, :export_csv]

  include GroupsHelper

  def index
    group_array  = []
    groups       = @context.get(:groups, @options)
    group_array << groups
  
    unless params[:per_page]
      @page = 1
      group_array, group_hash = check_paging(groups, group_array, "groups", @context, true)
    else
      group_array.flatten!
    end

    respond_to do |format|
      format.json { render :json => group_array }
    end
  end

  def show
    group = Group.find(params[:id], :params => @options)

    respond_to do |format|
      format.json { render :json => group }
    end
  end

  def create
    group = @context.post(:groups, @options)

    respond_to do |format|
      format.json { render :json => group.body }
    end
  end

  def destroy
    group = Group.destroy(params[:id], :params => @options)

    respond_to do |format|
      format.json { render :json => group }
    end
  end

  # Non-RESTful Methods
  # Export results to a csv file
  def export_csv

    group_array = []
    @page       = 1
    @per_page   = 50

    groups      = @context.get(:groups, :page => @page, :per_page => @per_page, :access_token => ENV["API_TOKEN"])
    group_array << groups
    group_array, group_hash = check_paging(groups, group_array, "groups", @context, true)

    group_array.each_with_index do |group, index|
      is_new            = index == 0 ? true : false
      membership_array  = []
      @page             = 1

      group_model       = Group.find(group['id'], :params => { :access_token => ENV["API_TOKEN"] })
      memberships       = group_model.get(:memberships, :page => @page, :per_page => @per_page, :access_token => ENV["API_TOKEN"])
      membership_array  << memberships
      membership_array, @membership_hash = check_paging(memberships, membership_array, "memberships", group_model, is_new)
    end

    export_data = [group_array, @membership_hash]
    perform_export(export_data) 

    respond_to do |format|
      format.html { render :inline => "<a href=<%= @download_url %>>Download CSV</a>" }
      format.json { render :json => @download_url.to_json }
    end
  end

end