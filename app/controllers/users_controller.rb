class UsersController < ApplicationController
  
  before_filter :get_context

  def index
    
    # Get unassigned users in a group_category
    # Add to options hash
    if params[:group_category_id] && params[:unassigned]
      @options[:unassigned] = params[:unassigned]
    end

    @user_array = []
    @users      = @context.get(:users, @options)
    @user_array << @users

    check_user_paging(@users, @context)

    respond_to do |format|
      format.json { render :json => @user_array }
    end
  end

  def masquerade
    if session[:masquerade_as].nil?
      if params[:user_id].nil?
        redirect_to root_path
      else
        session[:masquerade_as] = params[:user_id]
      end
    else
      session.delete(:masquerade_as)
    end
    redirect_to request.referrer
  end

end