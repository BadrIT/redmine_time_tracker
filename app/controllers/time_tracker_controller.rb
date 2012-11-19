class TimeTrackerController < TimelogController
  unloadable
  
  skip_before_filter :authorize
  before_filter :require_login
  accept_api_auth :activities, :trackers, :my_trackable_opened_issues
  prepend_before_filter :find_scrum_project, :only => [:get_trackable_opened_issues, :activities]
  
  def activities
    @activities = @project ? @project.activities : TimeEntryActivity.all

    respond_to do |format|
      format.xml
    end
  end
  
  def trackers
    if Tracker.new.respond_to?(:is_scrum)
      @trackers = Tracker.find_all_by_is_scrum(true)
    else
      @trackers = Tracker.all
    end
    
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
