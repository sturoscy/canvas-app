class SectionsController < ApplicationController

  before_filter :get_context

  def index
    @options[:include] = ["students"]
    @sections = @context.get(:sections, @options)
    
    respond_to do |format|
      format.json { render :json => @sections }
    end
  end

  def show
    @sections = @context.get(:sections, :access_token => ENV["API_TOKEN"], :include => ["students"])
    @section  = @sections.detect { |section| section["id"] == params[:id].to_i }

    respond_to do |format|
      format.json { render :json => @section }
    end
  end

end