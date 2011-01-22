Given /^someone named "([^"]*)" attended the first meeting$/ do |name|
  meeting = if Meeting.all.empty? then Factory.create(:meeting) else Meeting.first end
  meeting.attendees.create :person_name => name
end
