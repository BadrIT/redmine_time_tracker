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
    in_progress_id = IssueStatus.status_in_progress.id
    defined_id = IssueStatus.status_defined.id
    
    @issues = if @project
     @project.issues.trackable.find(:all,
                                    :conditions =>['assigned_to_id = ? AND ( status_id = ? OR status_id = ?', @user.id, in_progress_id, defined_id])      
    else
     Issue.trackable.find(:all,
                          :conditions =>['assigned_to_id = ? AND status_id = ?', @user.id, in_progress_id])
    end
    
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
