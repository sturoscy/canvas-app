class CoursesController < ApplicationController

  skip_before_filter :per_page_param 
  before_filter :get_context, :only => [:index]
  
  def index
    course_array  = []
    @courses      = @context.get(:courses, @options)
    course_array  << @courses

    unless params[:per_page]
      @page = 1
      course_array, course_hash = check_paging(@courses, course_array, "courses", @context, true)
    else
      course_array.flatten!
    end

    respond_to do |format|
      format.json { render :json => course_array }
    end
  end

  def show 
    @course = Course.find(params[:id], :params => @options)

    respond_to do |format|
      format.json { render :json => @course }
    end
  end

  def create
    @course = Course.new
    @course.account_id  = params[:account_id]
    @course.name        = params[:name]
    @course.course_code = params[:course_code]
    @course.sis_course_id     = params[:sis_course_id]
    @course.hide_final_grades = true
    @course.save

    respond_to do |format|
      format.json { render :json => @course }
    end
  end

end
