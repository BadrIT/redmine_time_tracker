class TimeTrackerController < ApplicationController
  unloadable
  
  prepend_before_filter :find_scrum_project, :only => [:get_trackable_opened_issues, :activities]
  
  def activities
    @activities = @project ? @project.activities : TimeEntryActivity.all
        
    respond_to do |format|
      format.xml
    end
  end
  
  def trackers
    @trackers = Tracker.find_all_by_is_scrum(true)
    
    respond_to do |format|
      format.xml
    end
  end
  
  def my_trackable_opened_issues
    @user = User.current
    
    @issues = if @project
     @project.issues.trackable.active.find(:all, :conditions =>['assigned_to_id = ?', @user.id])      
    else
     Issue.trackable.active.find(:all, :conditions =>['assigned_to_id = ?', @user.id])
    end
    
    respond_to do |format|
      format.xml
    end
  end
  
  def time_entries
    @time_entries = TimeEntry.all
    
    respond_to do |format|
      format.xml
    end
  end
  
  protected
  def find_scrum_project
    if params[:project_id]
      project_id = params[:project_id]
      @project = Project.find(project_id)
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
