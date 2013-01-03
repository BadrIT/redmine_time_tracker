xml.instruct!
xml.activities :type => 'array' do
  @activities.each do |activity|
    xml.activity do
      xml.id          activity.id
      if project_id = @project.try(:id) || activity.project_id
        xml.project(:id => project_id)
      end
      xml.name        activity.name
      xml.position    activity.position
    end
  end
end
