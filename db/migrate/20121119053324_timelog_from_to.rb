class TimelogFromTo < ActiveRecord::Migration
  def self.up
    add_column :time_entries, :spent_from, :datetime
    add_column :time_entries, :spent_to, :datetime
    
    add_index :time_entries, [:project_id, :user_id, :issue_id, :spent_on], :name=>'time_entries_merge_index'
  end

  def self.down
    remove_index :time_entries, :name=>'time_entries_merge_index'
    remove_column :time_entries, :spent_to
    remove_column :time_entries, :spent_from
  end
end
