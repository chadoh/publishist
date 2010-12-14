Then /^(?:|I )should not see "([^"]*)" under "([^"]*)"/ do |text, heading|
  find("section##{heading.parameterize('_')}").should have_no_content(text)
end

Then /^(?:|I )should see "([^"]*)" under "([^"]*)"/ do |text, heading|
  find("section##{heading.parameterize('_')}").should have_content(text)
end

Then /^(?:|I )should see a "([^"]*)" link under "([^"]*)"/ do |text, heading|
  find("section##{heading.parameterize('_')}").find("a", :text => text)
end

Given /^(?:there is )a person named "([^"]*)" with email address "([^"]*)"$/ do |name, email|
  name = name.split
  Person.create(
    :first_name => name.first,
    :last_name  => name.last,
    :email      => email,
    :password   => 'secret',
    :password_confirmation => 'secret')
end
