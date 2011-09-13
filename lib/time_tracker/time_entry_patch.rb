module TimeTracker
  module TimeEntryPatch
    
    def self.included(base)
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        include InstanceMethods

        after_save :update_issue
        
        after_destroy :update_issue_history
      end
    end
    
    module InstanceMethods
      def update_issue
        self.issue.status = IssueStatus.in_progress
        self.issue.save
      end
      
      def start_time
        start_time_custom_field = TimeEntryCustomField.find_by_name 'Start time'
        self.custom_value_for(start_time_custom_field).try(:value)
      end
      
      def update_issue_history
        self.issue.check_history_entries
      end
    end
  end
end