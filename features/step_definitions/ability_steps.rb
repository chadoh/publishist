Given /^I'm in a position for the current magazine with the "([^"]+)" ability$/ do |key|
  @person = Person.create(
    name:                  "example@example.com",
    email:                 "example@example.com",
    password:              "secret",
    password_confirmation: "secret"
  )
  @person.confirm!
  @magazine = Magazine.create(
    title: 'Awesome Mag',
    accepts_submissions_from:  3.months.ago,
    accepts_submissions_until: 3.months.from_now
  )
  @ability = Ability.create key: key, description: "#{key}s stuff"
  @position = @magazine.positions.create name: 'Kitten', abilities: [@ability]
  @person.positions << @position
  visit '/sign_in'
  fill_in 'Email', :with => @person.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

Given /^I'm in a position for (?:the "[^"]+"|said) magazine with the "([^"]+)" ability$/ do |key|
  @person = Person.create(
    name:                  "example@example.com",
    email:                 "example@example.com",
    password:              "secret",
    password_confirmation: "secret"
  )
  @person.confirm!
  @magazine = Magazine.first
  @ability = Ability.create key: key, description: "#{key}s stuff"
  @position = @magazine.positions.create name: 'Kitten', abilities: [@ability]
  @person.positions << @position
  visit '/sign_in'
  fill_in 'Email', :with => @person.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end

Given /^I'm in a position for the current magazine with the "([^"]+)" and "([^"]+)" abilities$/ do |key1, key2|
  @person = Person.create(
    name:                  "example@example.com",
    email:                 "example@example.com",
    password:              "secret",
    password_confirmation: "secret"
  )
  @person.confirm!
  @magazine = Magazine.create(
    title: 'Awesome Mag',
    accepts_submissions_from:  3.months.ago,
    accepts_submissions_until: 3.months.from_now
  )
  @ability1 = Ability.create key: key1, description: "#{key1}s stuff"
  @ability2 = Ability.create key: key2, description: "#{key2}s stuff"
  @position = @magazine.positions.create name: 'Kitten', abilities: [@ability1, @ability2]
  @person.positions << @position
  visit '/sign_in'
  fill_in 'Email', :with => @person.email
  fill_in 'Password', :with => 'secret'
  click_button 'Sign in'
end
