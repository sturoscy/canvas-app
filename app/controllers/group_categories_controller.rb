class GroupCategoriesController < ApplicationController

  before_filter :get_context, :only => [:index, :create]

  def index
    @group_categories = @context.get(:group_categories, @options)

    respond_to do |format|
      format.json { render :json => @group_categories }
    end
  end

  def show
    @group_category = GroupCategory.find(params[:id], :params => @options)

    respond_to do |format|
      format.json { render :json => @group_category }
    end
  end

  def create
    @group_category = @context.post(:group_categories, :name => params[:name], :access_token => ENV["API_TOKEN"])

    respond_to do |format|
      format.json { render :json => @group_category.body }
    end
  end

  def destroy
    @group_category = GroupCategory.delete(params[:id], :access_token => ENV["API_TOKEN"])

    respond_to do |format|
      format.json { render :json => @group_category }
    end
  end

end
