Given /^someone named "([^"]*)" attended the first meeting$/ do |name|
  meeting = first_meeting
  meeting.attendees.create :person_name => name
end
