module TimeTracker
	module IssuePatch
		
		def self.included(base)
			base.class_eval do
				unloadable # Send unloadable so it will not be unloaded in development
				
				include InstanceMethods

				scope :active, lambda { |*args| {:conditions => ["status_id in (?)", IssueStatus.where('is_closed = ?', false)]} }
				
		  end
		end
		
		module InstanceMethods
			
		end
	end
end