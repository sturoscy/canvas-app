class AccountsController < ApplicationController

  def index
    account = Account.find(:first, :params => @options)

    respond_to do |format|
      format.json { render :json => account }
    end
  end

  def show
    account = Account.find(params[:id], :params => @options)

    respond_to do |format|
      format.json { render :json => account }
    end
  end
end
