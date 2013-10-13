Then /^(?:|I )should see "([^"]*)" under "([^"]*)"/ do |text, heading|
  begin
    find("##{heading.parameterize('_')}").should have_content(text)
  rescue Capybara::ElementNotFound
    find("#submission_#{Submission.find_by_title(heading).id}").should have_content(text)
  end
end

Then /^(?:|I )should not see "([^"]*)" under "([^"]*)"/ do |text, heading|
  begin
    find("##{heading.parameterize('_')}").should have_no_content(text)
  rescue Capybara::ElementNotFound
    find("#submission_#{Submission.find_by_title(heading).id}").should have_no_content(text)
  end
end

Then /^I should see my name under "([^"]*)"$/ do |heading|
  find("##{heading.parameterize('_')}").should have_content(@person.name)
end

Then /^I should not see my name under "([^"]*)"$/ do |heading|
  find("##{heading.parameterize('_')}").should have_no_content(@person.name)
end

Then /^I should see that "([^"]*)" is not a link$/ do |text|
  page.should have_content(text)
  page.should_not have_css('a', text: text)
end

Then /^I should see that "([^"]*)" is a link$/ do |text|
  page.should have_content(text)
  page.should have_css('a', text: text)
end

Then /^(?:|I )should see a "([^"]*)" link$/ do |text|
  find("a", :text => text)
end

Then /^(?:|I )should see a "([^"]*)" link under "([^"]*)"/ do |text, heading|
  find("section##{heading.parameterize('_')}").find("a", :text => text)
end

Given /^(?:there is )a person named "([^"]*)" with email address "([^"]*)"$/ do |name, email|
  name = name.split
  p = Person.create(
    first_name: name.first,
    last_name: name.last,
    email: email,
    password: 'secret',
    password_confirmation: 'secret',
    primary_publication: Publication.first
  )
  p.confirm!
end

Then /^(?:|I )should see "([^"]*)" (\d+)(?:x|X| times?)?$/ do |phrase, count|
  (page.find("body").text.split(phrase).length - 1).should == count.to_i
end

When /^I fill in "([^"]*)" with my email address$/ do |field|
  fill_in(field, :with => @person.email)
end

When(/^I click the edit link$/) do
  find(:css, "[title^=Edit]").click
end
Then(/^I should see an edit link under "(.*?)"/) do |heading|
  begin
    find("##{heading.parameterize('_')}").should have_css('[title=Edit]')
  rescue Capybara::ElementNotFound
    find("#submission_#{Submission.find_by_title(heading).id}").should have_css('[title=Edit]')
  end
end

When(/^I click the remove link$/) do
  find(:css, "[data-method=delete]").click
end

When(/^I press the unpublish button$/) do
  find(:css, "[title^=Unpublish]").click
end
