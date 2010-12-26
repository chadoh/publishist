Given /^there are several submissions$/ do
  3.times { Factory.create :submission }
end

Given /^there are several meetings$/ do
  2.times { Factory.create :meeting }
end

When /^I drag "([^"]*)" to "([^"]*)"$/ do |submission_name, destination|
  submission = find("li", :text => submission_name).find("span.drag-handle")
  destination = find "section##{destination.parameterize('_')}"
  submission.drag_to destination
end

When /^I drag "([^"]*)" from "([^"]*)" to "([^"]*)"$/ do |submission_name, origin, destination|
  origin      = find "section##{origin.parameterize('_')}"
  submission = origin.find("li", :text => submission_name).find("span.drag-handle")
  destination = find "section##{destination.parameterize('_')}"
  submission.drag_to destination
end

Given /^the following submissions are scheduled for a meeting a week from now:$/ do |submissions_table|
  meeting = Factory.create :meeting
  submissions_table.hashes.each do |attributes|
    submission = Submission.create(attributes)
    Packet.create :meeting => meeting, :submission => submission
  end
end

When /^I drag "([^"]*)" on top$/ do |title|
  packet = find("li", :text => title).find('span.drag-handle')
  destination = find "section#packet li > footer"
  packet.drag_to destination
  # When you get this working, post how here: http://stackoverflow.com/questions/4044327/how-can-i-test-jquery-ui-sortable-with-cucumber
end

When /^I refresh the page$/ do
  visit URI.parse(current_url).path
end

Then /^"([^"]*)" should be above "([^"]*)"$/ do |top, bottom|
  page.body.should =~ /#{top}.*#{bottom}/m
end
