When /^I follow "([^"]*)" under "([^"]*)"$/ do |link_text, heading|
  element = "li#submission_#{Submission.find_by_title(heading).id}"
  When %Q{I follow "#{link_text}" within "#{element}"}
end

Then /^"([^"]*)" should be submitted, not draft$/ do |title|
  Submission.find_by_title(title).state.should == :submitted
end

Given /^I have drafted a poem called "([^"]*)"$/ do |title|
  @person.submissions.create :title => title,
                           :body => "Yes, I said it. #{title}!"
end

Given /^I have submitted a poem called "([^"]*)"$/ do |title|
  @person.submissions.create :title => title,
                           :body => "Yes, I said it. #{title}!",
                           :state => :submitted
end

When /^"([^"]*)" is scheduled for a meeting a week from now$/ do |title|
  meeting = first_meeting
  meeting.update_attribute :datetime, 1.week.from_now
  meeting.submissions << Submission.find_by_title(title)
end

Given /^the "([^"]*)" meeting is two hours away$/ do |submission_title|
  submission = Submission.find_by_title(submission_title)
  meeting = submission.packlets.first.meeting
  meeting.update_attribute(
    :datetime, 2.hours.from_now
  )
end

Given /^I have gone to the meeting and scored "([^"]*)"$/ do |title|
  meeting = first_meeting
  submission = Submission.find_by_title title
  submission.update_attributes magazine: Magazine.first
  meeting.submissions << submission
  meeting.people << @person
  submission.packlets.first.scores.create :amount => 6, :attendee => meeting.attendees.first
end

Then /^the submission should be submitted, not draft$/ do
  Submission.first.state.should == :submitted
end

Then /^"([^"]*)" should be published$/ do |title|
  Submission.find_by_title(title).state.should == :published
end
