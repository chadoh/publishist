Given /^there is a meeting scheduled$/ do
  Meeting.create datetime: 7.days.from_now, question: "orly?", issue: Issue.first
end

Given /^there is a meeting with the question "([^"]*)" that is somehow orphaned$/ do |question|
  Meeting.create datetime: 1.week.from_now, question: question
end
