module RedmineScrummer
  module CustomValuePatch
    
    def self.included(base)
      base.class_eval do
        unloadable # Send unloadable so it will not be unloaded in development
        
        include InstanceMethods
        
        after_save :sync_spent_values
      end
      
    end
    
    module InstanceMethods
      
      def sync_spent_values
        if self.custom_field.name == "Start time"
          time_entry = self.customized

          start_at = Time.parse("#{time_entry.spent_on} #{self.value}")

          if time_entry.spent_from != start_at 
            end_at = start_at.advance(:hours => time_entry.hours)
            time_entry.update_attributes(:spent_from => start_at, :spent_to => end_at)
          end
        end
      end

    end
   
  end
end