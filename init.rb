require 'redmine'
require 'dispatcher'

Dispatcher.to_prepare :time_tracker do
  require_dependency 'issue'
  
  unless Issue.included_modules.include? TimeTracker::IssuePatch
    Issue.send :include, TimeTracker::IssuePatch
  end
  
end

Redmine::Plugin.register :redmine_time_tracker do
  name 'Redmine Time Tracker plugin'
  author 'BadrIT'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://www.badrit.com'
  
  
  project_module :scrummer do
    permission :time_tracker,  { :time_tracker => [:activities, :trackers, :get_trackable_opened_issues] }

  end
end
