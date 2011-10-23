Given /^I did not attend the first meeting$/ do
end

Given /^I attend the first meeting$/ do
  Attendee.create(
    :meeting => first_meeting,
    :person => Person.first)
end

Given /^I and (\d) more people attend the first meeting$/ do |number|
  att = Attendee.create(
    :meeting => first_meeting,
    :person => Person.first)
  number.to_i.times do
    Attendee.create(
      :meeting => first_meeting,
      :person => Factory.create(:person))
  end
end

Given /^scores have been entered for a meeting$/ do
  meeting = first_meeting
  submiss = Submission.create title: "we the", body: "people", author_email: "example@example.com"
  packlet = meeting.packlets.create :submission => submiss
  attende = meeting.attendees.create :person => @user
  packlet.scores.create :amount => 6, :attendee => attende
end

Given /^there is a submission called "([^"]*)" scheduled for the first meeting$/ do |title|
  submission = Submission.create(
    :title => title,
    :body => "Yes, I said it. #{title}.",
    :author_email => "chad@chadoh.com")
  meeting = first_meeting
  Packlet.create(
    :meeting => meeting,
    :submission => submission)
end

When /^I score "([^"]*)"$/ do |title|
  fill_in "score_amount", :with => 6
  click_button "+"
end

Then /^I should be able to score "([^"]*)"$/ do |title|
  fill_in "score_amount", :with => 6
  click_button "+"
end

Then /^I should not be able to score "([^"]*)"$/ do |title|
  find('li', :text => title).should_not have_field("score_amount")
end

Then /^I should see (\d) score fields$/ do |number|
  page.should have_field("score_amount", :count => number)
end
