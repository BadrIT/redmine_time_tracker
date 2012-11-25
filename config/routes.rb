RedmineApp::Application.routes.draw do
  match '/time_tracker/:action(.:format)', :controller => "time_tracker", :as => :plugin_route
end