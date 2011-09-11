xml.instruct!
xml.activities :type => 'array' do
  @issues.each do |issue|
    xml.issue do
      xml.id          issue.id
      xml.subject     issue.subject
      xml.tracker_id  issue.id
	  xml.project_id  issue.project_id
    end
  end
end
