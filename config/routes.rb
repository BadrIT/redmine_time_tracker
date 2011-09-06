ActionController::Routing::Routes.draw do |map|
  map.plugin_route 'time_tracker/:action.:format', :controller => "time_tracker"
end