When /^I follow "([^"]*)" under "([^"]*)"$/ do |link_text, heading|
  element = "li#submission_#{Submission.find_by_title(heading).id}"
  When %Q{I follow "#{link_text}" within "#{element}"}
end

Then /^"([^"]*)" should be submitted, not draft$/ do |title|
  Submission.find_by_title(title).state.should == :submitted
end

Given /^I have drafted a poem called "([^"]*)"$/ do |title|
  @user.submissions.create :title => title,
                           :body => "Yes, I said it. #{title}!"
end

Given /^I have submitted a poem called "([^"]*)"$/ do |title|
  @user.submissions.create :title => title,
                           :body => "Yes, I said it. #{title}!",
                           :state => :submitted
end

When /^I schedule "([^"]*)" for a meeting a week from now$/ do |title|
  meeting = Factory.create :meeting
  meeting.submissions << Submission.find_by_title(title)
end
