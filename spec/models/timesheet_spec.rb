require File.dirname(__FILE__) + '/../spec_helper'

module TimesheetSpecHelper
  def project_factory(id)
    # First project
    project = mock_model(Project, :parent => nil, :id => id, :to_param => id.to_s)
    project_te1 = mock_model(TimeEntry, :id => '100' + id.to_s, :project_id => project.id, :issue_id => '1', :hours => '5', :activity_id => '1', :spent_on => Date.today)
    project_te2 = mock_model(TimeEntry, :id => '101' + id.to_s, :project_id => project.id, :issue_id => '1', :hours => '10', :activity_id => '1', :spent_on => Date.today)
    project_time_entries_mock = mock('project_time_entries_mock')
    project_time_entries_mock.stub!(:find).and_return([project_te1, project_te2])
    project.stub!(:time_entries).and_return(project_time_entries_mock)
    project.stub!(:name).and_return('Project ' + id.to_s)
    
    return project
  end
end

describe Timesheet do
  it 'should not be an ActiveRecord class' do
    Timesheet.should_not be_a_kind_of(ActiveRecord::Base)
  end
  
  it 'should initialize time_entries to an empty Hash' do 
    timesheet = Timesheet.new
    timesheet.time_entries.should be_a_kind_of(Hash)
    timesheet.time_entries.should be_empty
  end

  it 'should initialize projects to an empty Array' do 
    timesheet = Timesheet.new
    timesheet.projects.should be_a_kind_of(Array)
    timesheet.projects.should be_empty
  end

  it 'should initialize allowed_projects to an empty Array' do 
    timesheet = Timesheet.new
    timesheet.allowed_projects.should be_a_kind_of(Array)
    timesheet.allowed_projects.should be_empty
  end

  it 'should initialize activities to an empty Array' do 
    timesheet = Timesheet.new
    timesheet.activities.should be_a_kind_of(Array)
    timesheet.activities.should be_empty
  end

  it 'should initialize users to an empty Array' do 
    timesheet = Timesheet.new
    timesheet.users.should be_a_kind_of(Array)
    timesheet.users.should be_empty
  end
end

describe Timesheet,'.fetch_time_entries' do
  include TimesheetSpecHelper
  
  it 'should clear .time_entries' do
    timesheet = Timesheet.new
    timesheet.time_entries = { :filled => 'data' }
    proc { 
      timesheet.fetch_time_entries
    }.should change(timesheet, :time_entries)
    
  end

  it 'should add a time_entry array for each project' do
    timesheet = Timesheet.new
    timesheet.date_from = Date.today.to_s
    timesheet.date_to = Date.today.to_s

    project1 = project_factory(1)
    project2 = project_factory(2)

    timesheet.projects = [project1, project2]
    
    timesheet.fetch_time_entries
    timesheet.time_entries.should_not be_empty
    timesheet.time_entries.should have(2).things
  end
  
  it 'should use the project name for each time_entry array' do 
    timesheet = Timesheet.new
    timesheet.date_from = Date.today.to_s
    timesheet.date_to = Date.today.to_s

    project1 = project_factory(1)
    project1.should_receive(:name).and_return('Project 1')
    project2 = project_factory(2)
    project2.should_receive(:name).and_return('Project 2')

    timesheet.projects = [project1, project2]
    
    timesheet.fetch_time_entries
    timesheet.time_entries.should include("Project 1")
    timesheet.time_entries.should include("Project 2")
  end

  it 'should add the parent project name for each time_entry array for sub-projects'
  it 'should fetch all the time entries on a project in the date range'
  it 'should fetch all the time entries on a project matching the activities'
  it 'should fetch all the time entries on a project matching the users'
end

