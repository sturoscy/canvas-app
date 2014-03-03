class SyncedGroupCategoriesController < ApplicationController

  skip_before_filter :per_page_params

  def index
    @synced_group_categories = SyncedGroupCategory.updated_desc

    respond_to do |format|
      format.html
      format.json { render :json => @synced_group_categories }
    end
  end

  def show
    synced_group_category = SyncedGroupCategory.find(params[:id])

    respond_to do |format|
      format.json { render :json => synced_group_category }
    end
  end

  def new
  end

  def create
    synced_group_category = SyncedGroupCategory.new
    synced_group_category.group_category_id   = params[:group_category_id]
    synced_group_category.group_category_name = params[:group_category_name]
    synced_group_category.course_id           = params[:course_id]
    synced_group_category.course_code         = params[:course_code]
    synced_group_category.deleted             = params[:deleted]
    synced_group_category.save

    respond_to do |format|
      format.json { render :json =>  synced_group_category }
    end
  end

  def update
    synced_group_category = SyncedGroupCategory.find(params[:id])
    synced_group_category.touch
    synced_group_category.save

    respond_to do |format|
      format.json { render :json => synced_group_category }
    end
  end

  def destroy
    synced_group_category = SyncedGroupCategory.find(params[:id])
    logger.info "Synced Category: #{synced_group_category.group_category_id} deleted from Course: #{synced_group_category.course_id} on #{Time.now}"
    synced_group_category.delete

    respond_to do |format|
      format.json { render :json => synced_group_category }
    end
  end
end