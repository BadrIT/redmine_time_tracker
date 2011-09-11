module TimeTracker
  module TimeEntryPatch
    
    def self.included(base)
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        include InstanceMethods

        after_save :update_issue
        
      end
    end
    
    module InstanceMethods
      def update_issue
        self.issue.status = IssueStatus.in_progress
        self.issue.save
      end
      
    end
  end
end