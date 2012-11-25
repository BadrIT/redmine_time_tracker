require 'redmine'

Rails.configuration.to_prepare do
  require_dependency 'issue'
  
  unless Issue.included_modules.include? TimeTracker::IssuePatch
    Issue.send :include, TimeTracker::IssuePatch
  end
  
  unless TimeEntry.included_modules.include? TimeTracker::TimeEntryPatch
    TimeEntry.send :include, TimeTracker::TimeEntryPatch
  end
end

Redmine::Plugin.register :redmine_time_tracker do
  name 'Redmine Time Tracker plugin'
  author 'BadrIT'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://www.badrit.com'

  menu :top_menu, :log_time, {:controller => 'timelog', :action => 'new' }, :caption => 'Log time', :if => Proc.new { User.current.logged? }

  menu :top_menu, :time_details, {:controller => 'timelog', :action => 'report', :criterias=>['member', 'issue'], :columns=>'day', :period=>'current_week', :user_id=>''}, :caption => 'Time details', :require => :loggedin, :if => Proc.new { !(User.current.projects.blank?) }

  menu :top_menu, :time_chart, {:controller => 'time_tracker', :action => 'charts', :period => 'current_week'}, :caption => 'Time charts', :if => Proc.new { User.current.logged? }
end
