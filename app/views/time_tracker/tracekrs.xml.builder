xml.instruct!
xml.trackers :type => 'array' do
  @trackers.each do |t|
    xml.tracker do
      xml.id          		t.id
      xml.name		  		t.name
      xml.short_name  		t.short_name
    end
  end
end
