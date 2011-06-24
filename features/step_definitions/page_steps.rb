Then /^I should see "([^"]*)" for the page numbers$/ do |text|
  Then "I should see \"#{text}\" within \"nav.pagination\""
end
