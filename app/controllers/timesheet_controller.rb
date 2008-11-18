class TimesheetController < ApplicationController
  unloadable

  layout 'base'
  before_filter :get_list_size
  before_filter :get_precision
  before_filter :get_activities

  helper :sort
  include SortHelper
  helper :issues
  include ApplicationHelper

  def index
    @from = Date.today.to_s
    @to = Date.today.to_s
    @timesheet = Timesheet.new
    @timesheet.allowed_projects = allowed_projects
    
    if @timesheet.allowed_projects.empty?
      render :action => 'no_projects'
      return
    end
  end

  def report
    if params && params[:timesheet]
      @timesheet = Timesheet.new( params[:timesheet].merge({ :sort => :user }) )
    else
      @timesheet = Timesheet.new({ :sort => :user })
    end
    
    @timesheet.allowed_projects = allowed_projects
    
    if @timesheet.allowed_projects.empty?
      render :action => 'no_projects'
      return
    end

    if !params[:timesheet][:projects].blank?
      @timesheet.projects = @timesheet.allowed_projects.find_all { |project| 
        params[:timesheet][:projects].include?(project.id.to_s)
      }
    else 
      @timesheet.projects = @timesheet.allowed_projects
    end

    call_hook(:plugin_timesheet_controller_report_pre_fetch_time_entries, { :timesheet => @timesheet, :params => params })

    @timesheet.fetch_time_entries

    # Sums
    @total = { }
    @timesheet.time_entries.each do |project,logs|
      project_total = 0
      unless logs[:logs].nil?
        logs[:logs].each do |log|
          project_total += log.hours
        end
        @total[project] = project_total
      end
    end
    
    @grand_total = @total.collect{|k,v| v}.inject{|sum,n| sum + n}

    send_csv and return if 'csv' == params[:export]
    render :action => 'details', :layout => false if request.xhr?
  end
  
  def context_menu
    @time_entries = TimeEntry.find(:all, :conditions => ['id IN (?)', params[:ids]])
    render :layout => false
  end

  private
  def get_list_size
    @list_size = Setting.plugin_timesheet_plugin['list_size'].to_i
  end

  def get_precision
    @precision = Setting.plugin_timesheet_plugin['precision'].to_i
  end
  def get_activities
    @activities = Enumeration::get_values('ACTI')
  end
  
  def allowed_projects
    if User.current.admin?
      return Project.find(:all, :order => 'name ASC')
    else
      return User.current.projects.find(:all, :order => 'name ASC')
    end
  end
end
