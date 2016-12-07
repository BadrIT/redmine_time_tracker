class TimeTrackerController < TimelogController
  unloadable

  skip_before_filter :authorize
  before_filter :require_login
  accept_api_auth :activities, :trackers, :my_trackable_opened_issues, :users_hours_by_months, :users_hours_by_date_range
  prepend_before_filter :find_scrum_project, :only => [:my_trackable_opened_issues, :activities]

  # before_filter :authorize_global, :only => [:charts]

  def activities
    @activities = if @project
      @project.activities
    else
      User.current.projects.all(:include => :time_entry_activities).map(&:time_entry_activities).flatten + TimeEntryActivity.shared.active
    end

    respond_to do |format|
      format.xml
    end
  end

  def trackers
    @trackers = User.current.projects.all(:include => :trackers).map(&:trackers).flatten

    if Tracker.new.respond_to?(:is_scrum)
      @trackers = @trackers.select(&:is_scrum)
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

    # only issues assigned to active projects
    @issues = issues_scope.active.find(:all, :conditions =>['assigned_to_id = ? and projects.status = ?', @user.id, Project::STATUS_ACTIVE], :joins=> 'inner join projects on projects.id=issues.project_id',:include => 'project')

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

    @query = TimeEntryQuery.build_from_params(params, :name => '_')
    scope = time_entry_scope

    if User.current.admin && params[:user_id].present?
      @user = User.find(params[:user_id])
    else
      @user = User.current
    end

    scope = scope.where('user_id = ?', @user.id)

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

      format.json {
        entries = scope.find(:all,
              :include => [:project, :activity, :user, {:issue => :tracker}], :order=>'spent_from')
        render :json => entries
      }
    end
  end

  def users_hours_by_months
    quarter_year = params[:year]
    quarter_months = params[:months].split(',').map(&:to_i)

    @users_hours = User.all.inject({}) do |memo, user|

      memo["#{user.login}"] = quarter_months.inject({}) do |memo2, qm|
        memo2[qm] = TimeEntry.work_hours_per_user_per_year_per_month(user.id, quarter_year, qm).sum(:hours)
        memo2
      end

      memo
    end

    respond_to do |format|
      format.json { render :json => @users_hours }
    end
  end

  def users_hours_by_date_range
    from_date = params[:from]
    to_date = params[:to]

    #swap from into to date if from date greater than to date
    if(from_date > to_date)
      from_date,to_date = to_date,from_date
    end

    @users_hours = User.all.inject({}) do |memo, user|
      memo["#{user.login}"] = TimeEntry.work_hours_per_user_by_date_range(user.id, from_date, to_date).sum(:hours)
      memo
    end

    respond_to do |format|
      format.json { render :json => @users_hours }
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
