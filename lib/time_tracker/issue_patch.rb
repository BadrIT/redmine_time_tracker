module TimeTracker
	module IssuePatch
		
		def self.included(base)
			base.class_eval do
				unloadable # Send unloadable so it will not be unloaded in development
				
				include InstanceMethods
				
        named_scope :trackable, lambda { |*args| {:conditions => ["tracker_id = ? OR tracker_id = ? OR tracker_id = ? OR tracker_id = ?",
                                                                Tracker.scrum_task_tracker.id,
                                                                Tracker.scrum_defect_tracker.id,
                                                                Tracker.scrum_refactor_tracker.id,
                                                                Tracker.scrum_spark_tracker.id]} }
			end
		end
		
		module InstanceMethods
			
		end
	end
end