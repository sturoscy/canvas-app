class MembershipsController < ApplicationController

  skip_before_filter :per_page_param,  :only => [:index]
  before_filter :get_context, :only => [:index, :create]

  def index
    membership_array  = []
    memberships       = @context.get(:memberships, @options)
    membership_array  << memberships

    unless params[:per_page]
      @page = 1
      membership_array, membership_hash = check_paging(memberships, membership_array, "memberships", @context, true)
    else
      membership_array.flatten!
    end

    respond_to do |format|
      format.json { render :json => membership_array }
    end
  end
  
  def create
    @membership = @context.post(:memberships, @options)

    respond_to do |format|
      format.json { render :json => @membership.body }
    end
  end

end