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
      
      def attributes=(new_attributes, guard_protected_attributes = true)
        start_time = new_attributes[:start_time]
        
        if start_time
          start_time_custom_field = TimeEntryCustomField.find_by_name 'Start time'
          self.custom_field_values = {start_time_custom_field.id => start_time}
        end
        
        new_attributes.delete :start_time
        
        super(new_attributes, guard_protected_attributes = true)
      end
      
    end
  end
end