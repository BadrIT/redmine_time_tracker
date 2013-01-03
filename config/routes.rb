RedmineApp::Application.routes.draw do
  match '/time_tracker/:action(.:format)', :controller => "time_tracker", :as => :plugin_route
  match '/users_hours_by_months', :controller => 'time_tracker', :action=>'users_hours_by_months', :format=>'json'
end