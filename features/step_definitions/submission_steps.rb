When /^I follow "([^"]*)" under "([^"]*)"$/ do |link_text, heading|
  element = "li#submission_#{Submission.find_by_title(heading).id}"
  When %Q{I follow "#{link_text}" within "#{element}"}
end

Then /^"([^"]*)" should be submitted, not draft$/ do |title|
  Submission.find_by_title(title).state.should == :submitted
end
