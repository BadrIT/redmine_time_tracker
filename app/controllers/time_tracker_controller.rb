class TimeTrackerController < ApplicationController
  unloadable
  
  prepend_before_filter :find_scrum_project, :only => [:get_trackable_opened_issues, :activities]
  
  def activities
    @activities = @project.activities
        
    respond_to do |format|
      format.xml
    end
  end
  
  def tracekrs
    @trackers = Tracker.find_all_by_is_scrum(true)
    
    respond_to do |format|
      format.xml
    end
  end
  
  def get_trackable_opened_issues
    @user = User.current
    in_progress_id = IssueStatus.status_in_progress.id
    
    @trackable_opened_issues = @project.issues.trackable.find(:all,
                                                              :conditions =>['assigned_to_id = ? AND status_id = ?', @user.id, in_progress_id])
    respond_to do |format|
      format.xml  { render :xml => @trackable_opened_issues }
    end
  end
  
  protected
  def find_scrum_project
    project_id = params[:project_id]
    @project = Project.find(project_id)
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
