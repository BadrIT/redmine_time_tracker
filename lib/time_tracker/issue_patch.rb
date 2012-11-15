module TimeTracker
	module IssuePatch
		
		def self.included(base)
			base.class_eval do
				unloadable # Send unloadable so it will not be unloaded in development
				
				include InstanceMethods
				
		  end
		end
		
		module InstanceMethods
			
		end
	end
end