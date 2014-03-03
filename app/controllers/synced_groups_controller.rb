class SyncedGroupsController < ApplicationController
  
  before_filter :get_context, :only => [:index]
  
  def index
    if @context
      @synced_groups = @context.synced_groups.by_group_id
    else
      @synced_groups = SyncedGroup.by_group_id
    end

    respond_to do |format|
      format.json { render :json => @synced_groups }
    end
  end

  def show
    synced_group = SyncedGroup.find(params[:id])

    respond_to do |format|
      format.json { render :json => synced_group }
    end
  end

  def new
  end

  def create
    synced_group = SyncedGroup.new(
      :group_id     => params[:group_id],
      :group_name   => params[:group_name],
      :section_id   => params[:section_id],
      :section_name => params[:section_name],
      :course_id    => params[:course_id],
      :course_code  => params[:course_code],
      :skip_sync    => false,
      :synced_group_category_id => params[:synced_group_category_id]
    )
    synced_group.save

    respond_to do |format|
      format.json { render :json => synced_group }
    end
  end

  def update
    synced_group = SyncedGroup.find(params[:id])
    synced_group.group_id     = params[:group_id]
    synced_group.group_name   = params[:group_name]
    synced_group.section_id   = params[:section_id]
    synced_group.section_name = params[:section_name]
    synced_group.touch
    synced_group.save

    respond_to do |format|
      format.json { render :json => synced_group }
    end
  end

  def destroy
    synced_group = SyncedGroup.find(params[:id])
    synced_group.delete
    
    respond_to do |format|
      format.json { render :json => synced_group }
    end
  end
end
