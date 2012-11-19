class TimelogFromTo < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :spent_from, :datetime
    add_column :time_entries, :spent_to, :datetime
    
    TimeEntry.delete_all('hours = 0.0')
    TimeEntry.update_all('spent_from = spent_on')
    TimeEntry.update_all('spent_to=FLOOR(spent_from+Floor(hours)*10000+ ROUND((hours-FLOOR(hours))*60)*100)', 'hours < 24.0 AND hours > 0.0')
    TimeEntry.find(:all, :conditions=>'hours >= 24.0').each do |time_entry|
      time_entry.hours = time_entry.hours
      time_entry.save!
    end

    add_index :time_entries, [:project_id, :user_id, :issue_id, :spent_on], :name=>'time_entries_merge_index'
  end

  def self.down
    remove_index :time_entries, :name=>'time_entries_merge_index'
    remove_column :time_entries, :spent_to
    remove_column :time_entries, :spent_from
  end
end
