Given /^I'm in a position for the current issue with the "([^"]+)" ability$/ do |key|
  @person ||= Factory.create(:person, primary_publication: Publication.first)
  @person.confirm!
  @issue = Issue.create(
    title: 'Awesome Mag',
    accepts_submissions_from:  3.months.ago,
    accepts_submissions_until: 3.months.from_now,
    publication: Publication.first
  )
  @ability = Ability.create key: key, description: "#{key} stuff"
  @position = @issue.positions.create name: 'Kitten', abilities: [@ability]
  @person.positions << @position
  visit '/sign_in'
  fill_in 'Email', :with => @person.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

Given /^I'm in a position for (the "[^"]+"|said) issue with the "([^"]+)" ability$/ do |issue, key|
  title = issue.sub(/[^"]*"/, '').sub('"', '')
  @person ||= Factory.create(:person, primary_publication: Publication.first)
  @person.confirm!
  @issue = Issue.find_by_nickname(title) || Issue.first
  @ability = Ability.create key: key, description: "#{key}s stuff"
  @position = @issue.positions.create name: 'Kitten', abilities: [@ability]
  @person.positions << @position
  visit '/sign_in'
  fill_in 'Email', :with => @person.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

Given /^I'm in a position for the current issue with the "([^"]+)" and "([^"]+)" abilities$/ do |key1, key2|
  @person ||= Factory.create(:person, primary_publication: Publication.first)
  @person.confirm!
  @issue = Issue.create(
    title: 'Awesome Mag',
    accepts_submissions_from:  3.months.ago,
    accepts_submissions_until: 3.months.from_now,
    publication: Publication.first
  )
  @ability1 = Ability.create key: key1, description: "#{key1} stuff"
  @ability2 = Ability.create key: key2, description: "#{key2} stuff"
  @position = @issue.positions.create name: 'Kitten', abilities: [@ability1, @ability2]
  @person.positions << @position
  visit '/sign_in'
  fill_in 'Email', :with => @person.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

Given /^I have the "([^"]+)" ability for the current issue$/ do |key|
  @person ||= Person.first
  @issue = Issue.create(
    title: 'Awesome Mag',
    accepts_submissions_from:  3.months.ago,
    accepts_submissions_until: 3.months.from_now,
    publication: Publication.first
  )
  @ability = Ability.create key: key, description: "#{key}s stuff"
  @position = @issue.positions.create name: 'Kitten', abilities: [@ability]
  @person.positions << @position
end

Given /^I also have the "([^"]+)" ability for the "([^"]+)" issue$/ do |key, issue|
  @issue = Issue.find_by_nickname issue
  @ability = Ability.create key: key, description: "#{key}s stuff"
  @position = @issue.positions.create name: 'Kitten', abilities: [@ability]
  @person.positions << @position
end
