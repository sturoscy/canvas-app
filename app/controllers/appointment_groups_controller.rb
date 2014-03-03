class AppointmentGroupsController < ApplicationController
  require 'uri'

  skip_before_filter  :per_page_param
  
  def index
    @options[:scope]          = "manageable"
    @options[:context_codes]  = ["course_#{params[:course_id]}"]
    @options[:include]        = ["appointments", "child_events"]

    if params[:include_past_appointments]
      @options[:include_past_appointments] = true
    end

    appointment_groups = AppointmentGroup.find(:all, :params => @options)

    respond_to do |format|
      format.html
      format.json { render :json => appointment_groups }
    end
  end

  def show
    @options[:include]  = ["appointments", "child_events"]
    appointment_group   = AppointmentGroup.find(params[:id], :params => @options)

    respond_to do |format|
      format.json { render :json => appointment_group }
    end
  end

  def pdf
    html_input    = params[:html_to_convert]
    key_to_print  = params[:key_to_print]
    group_id      = params[:key_to_send]
    course_id     = params[:course_id]
    date = Time.now.strftime('%Y%m%d')

    # Use pdf kit to create file from html group data
    # Using the default bootstrap css file for print media
    pdf_kit   = PDFKit.new(html_input, :page_size => 'Letter')
    pdf_kit.stylesheets << "#{Rails.root}/app/assets/stylesheets/print/print.css"
    pdf_file  = pdf_kit.to_file("#{Rails.root}/public/files/course_#{course_id}_#{group_id}_#{date}.pdf")
    pdf_base  = File.basename(pdf_file)

    respond_to do |format|
      format.json { render :json => { :status => "Done Rendering", :key_to_print => key_to_print, :pdf_base => pdf_base } }
    end
  end
  
end
