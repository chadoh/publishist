When /^I promote (.*) to (.*)$/ do |person, rank|
  person = find("li", :text => person)
  person.click_button(rank.titleize)
end

Then /^I should see that (.*) (?:is|am) (now|still|not) (.*)/ do |person, negate, rank|
  if person == 'I' then person = "Chad" end
  person = find("li", :text => person)
  if negate == "not"
    person.find('.rank').should have_no_content(rank.titleize)
  else
    person.find('.rank').should have_content(rank.titleize)
  end
end
