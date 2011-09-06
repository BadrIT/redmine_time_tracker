class TimeEntryCustomFieldStartTime < ActiveRecord::Migration
  def self.up
    # add start_time custom field to TimeEntry
    start_time_custom_field = TimeEntryCustomField.find_or_create_by_scrummer_caption(:scrummer_caption => :start_time)
    start_time_custom_field.update_attributes(
                        :name          => "Start time",
                        :field_format  => 'string',
                        :regexp        => '\d\d:\d\d\s?[AM|PM|am|pm]',
                        :default_value => '00:00 AM')
  end

  def self.down
    start_time_custom_field = TimeEntryCustomField.find_by_scrummer_caption(:scrummer_caption => :start_time)
    start_time_custom_field.destroy
  end
end
