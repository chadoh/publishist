When /^I follow "([^"]*)" under "([^"]*)"$/ do |link_text, heading|
  element = "li#submission_#{Submission.find_by_title('link_text')}"
  When "I follow \"#{link_text}\" within \"#{element}\""
end
