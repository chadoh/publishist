Given /^I did not attend the first meeting$/ do
end

Given /^I attend the first meeting$/ do
  att = Attendance.create(
    :meeting => Factory.create(:meeting),
    :person => Person.first)
end

Given /^there is a submission called "([^"]*)" scheduled for the first meeting$/ do |title|
  submission = Submission.create(
    :title => title,
    :body => "Yes, I said it. #{title}.",
    :author_email => "chad@chadoh.com")
  meeting = Meeting.first || Factory.create(:meeting)
  Packet.create(
    :meeting => meeting,
    :submission => submission)
end

Then /^I should be able to score "([^"]*)"$/ do |title|
  fill_in "score_amount", :with => 6
  click_button "Save"
end

Then /^I should not be able to score "([^"]*)"$/ do |title|
  find('li', :text => title).should_not have_field("score_amount")
end
