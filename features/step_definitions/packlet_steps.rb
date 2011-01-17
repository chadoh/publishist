Given /^there are several submissions$/ do
  3.times { Factory.create :submission }
end

Given /^there are several meetings$/ do
  2.times { Factory.create :meeting }
end

When /^I drag "([^"]*)" to the (.*) meeting$/ do |submission_name, destination|
  destination = if destination == "first" then "meeting_#{Meeting.first.id}"
    else "meeting_#{Meeting.last.id}" end
  submission = find("li", :text => submission_name).find("span.drag-handle")
  destination = find "section##{destination}"
  submission.drag_to destination
end

Then /^I should see "([^"]*)" under the (.*) meeting$/ do |text, heading|
  section = if heading == "first" then "meeting_#{Meeting.first.id}"
    else "meeting_#{Meeting.last.id}" end
  find("section##{section}").should have_content(text)
end

Then /^I should not see "([^"]*)" under the (.*) meeting$/ do |text, heading|
  section = if heading == "first" then "meeting_#{Meeting.first.id}"
    else "meeting_#{Meeting.last.id}" end
  find("section##{section}").should_not have_content(text)
end

When /^I drag "([^"]*)" from the (.*) meeting to "([^"]*)"$/ do |submission_name, first_or_second, destination|
  meeting = first_or_second == "first" ? "meeting_#{Meeting.first.id}" : "meeting_#{Meeting.last.id}"
  origin  = find "section##{meeting}"

  submission  = origin.find("li", :text => submission_name).find("span.drag-handle")
  destination = find "section##{destination.parameterize('_')}"

  submission.drag_to destination
end

Given /^the following submissions are scheduled for a meeting a week from now:$/ do |submissions_table|
  meeting = Factory.create :meeting
  submissions_table.hashes.each do |attributes|
    submission = Submission.create(attributes)
    Packlet.create :meeting => meeting, :submission => submission
  end
end

When /^I drag "([^"]*)" on top$/ do |title|
  packlet = find("li", :text => title).find('span.drag-handle')
  destination = find "section#packlet li > footer"
  packlet.drag_to destination
  # When you get this working, post how here: http://stackoverflow.com/questions/4044327/how-can-i-test-jquery-ui-sortable-with-cucumber
end

When /^I refresh the page$/ do
  visit URI.parse(current_url).path
end

Then /^"([^"]*)" should be above "([^"]*)"$/ do |top, bottom|
  page.body.should =~ /#{top}.*#{bottom}/m
end
