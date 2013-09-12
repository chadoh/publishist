Given /^the following users? exists?:$/ do |table|
  table.rows_hash.each do |name, email|
    first_name, last_name = name.split(' ')
    person = Person.create(
      :first_name            => first_name,
      :last_name             => last_name,
      :email                 => email,
      :password              => "password",
      :password_confirmation => "password"
    )
    person.confirm!
  end
end

Given /^I sign in$/ do
  @person = Person.create(
    first_name:            "example@example.com",
    email:                 "example@example.com",
    password:              "secret",
    password_confirmation: "secret"
  )
  @person.confirm!
  visit '/sign_in'
  fill_in 'Email',    :with => "example@example.com"
  fill_in 'Password', :with => "secret"
  click_button 'Sign in'
end

Given /^I (?:am signed|sign) out$/ do
  click_link "Sign out"
end

Given /^I have an account but am not signed in$/ do
  person = Person.create(
    first_name:            "example@example.com",
    email:                 "example@example.com",
    password:              "secret",
    password_confirmation: "secret"
  )
  person.confirm!
end

Then /^there should be no new users$/ do
  Person.count == 0
end
