class TimeTrackerController < TimelogController
  unloadable
  
  before_filter :authorize, :except => [:index, :my_trackable_opened_issues, :activities, :trackers]
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
    
    issues_scope = if @project
      @project.issues
    else
      Issue
    end

    issues_scope = issues_scope.trackable if Issue.respond_to?(:trackable)
    
    @issues = issues_scope.active.find(:all, :conditions =>['assigned_to_id = ?', @user.id])
    
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
