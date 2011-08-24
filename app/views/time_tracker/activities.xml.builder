xml.instruct!
xml.activities :type => 'array' do
  @activities.each do |activity|
    xml.activity do
      xml.id          activity.id
      xml.project(:id => @project.id, :name => @project.name)
      xml.name        activity.name
      xml.position    activity.position
    end
  end
end
