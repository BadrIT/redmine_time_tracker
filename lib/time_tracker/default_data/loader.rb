module TimeTracker
  module DefaultData
    class DataAlreadyLoaded < Exception; end
    
    module Loader
      include Redmine::I18n
      
      class << self
        # Loads the default data
        def load(lang=nil)
          set_language_if_valid(lang)

          TimeEntry.delete_all('hours = 0.0')
          TimeEntry.update_all('spent_from = spent_on')
          TimeEntry.update_all('spent_to=FLOOR(spent_from+Floor(hours)*10000+ ROUND((hours-FLOOR(hours))*60)*100)', 'hours < 24.0 AND hours > 0.0')
          TimeEntry.find(:all, :conditions=>'hours >= 24.0').each do |time_entry|
            time_entry.hours = time_entry.hours
            time_entry.save!
          end
        end
      end
    end
  end
end