xml.instruct!
xml.activities :type => 'array' do
  @issues.each do |issue|
    xml.issue do
      xml.id          issue.id
      xml.subject     issue.subject
      xml.tracker_id  issue.id
    end
  end
end
