class TimeTrackerController < TimelogController
  unloadable
  
  skip_before_filter :authorize
  before_filter :require_login
  accept_api_auth :activities, :trackers, :my_trackable_opened_issues
  prepend_before_filter :find_scrum_project, :only => [:my_trackable_opened_issues, :activities]

  # before_filter :authorize_global, :only => [:charts]
  
  def activities
    @activities = @project ? @project.activities : current_user.projects.all(:include => :time_entry_activities).map(&:time_entry_activities).flatten

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

  def charts
    sort_init 'spent_from', 'desc'
    sort_update 'spent_from' => 'spent_from',
                'user' => 'user_id',
                'activity' => 'activity_id',
                'project' => "#{Project.table_name}.name",
                'issue' => 'issue_id',
                'hours' => 'hours'

    retrieve_date_range

    scope = TimeEntry.visible.spent_between(@from, @to).where('user_id = ?', User.current.id)

    respond_to do |format|
      format.html {
        entries = scope.find(:all, 
              :include => [:project, :activity, :user, {:issue => :tracker}], :order=>'spent_from')
        @entries_by_day = entries.group_by(&:spent_on)
        @min_hour = 25
        @max_hour = 0
        @entries_by_day.each do |day, entries|
          @min_hour = entries.first.spent_from.hour if entries.first.spent_from.hour < @min_hour
          @max_hour = entries.last.spent_to.hour if entries.last.spent_to.hour > @max_hour
        end
        @max_hour = @min_hour + 7 if @max_hour < @min_hour + 7
        @max_hour += 1
        @total_hours = scope.sum(:hours).to_f
        render :layout => !request.xhr?
      }
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
