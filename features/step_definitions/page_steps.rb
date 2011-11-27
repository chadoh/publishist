Then /^I should see "([^"]*)" for the page numbers$/ do |text|
  step "I should see \"#{text}\" within \"nav.pagination\""
end
