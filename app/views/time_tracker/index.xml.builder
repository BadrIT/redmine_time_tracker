xml.instruct!
xml.time_entries :type => 'array' do
  @entries.each do |t|
    xml.time_entry do
      xml.id         t.id
      xml.project    :name => t.project.name, :id => t.project_id
      xml.issue      :id   => t.issue_id
      xml.user       :name => t.user.name, :id => t.user_id
      xml.activity   :name=> t.activity.name, :id => t.activity_id
      xml.hours      t.hours
      xml.comments   t.comments
      xml.spent_on   t.spent_on
      xml.created_on t.created_on
      xml.updated_on t.updated_on
      xml.spent_from t.spent_from
      xml.spent_to   t.spent_to
    end
  end
end