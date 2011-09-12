xml.instruct!
xml.issues :type => 'array' do
  @issues.each do |issue|
    xml.issue do
      xml.id          issue.id
      xml.subject     issue.subject
      xml.tracker_id  issue.id
	  xml.project :name => issue.project.name, :id => issue.project_id
    end
  end
end
