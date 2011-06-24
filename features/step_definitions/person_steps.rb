Given /^the following users? exists?:$/ do |table|
  table.rows_hash.each do |name, email|
    first_name, last_name = name.split(' ')
    @user = Person.create(
      :first_name            => first_name,
      :last_name             => last_name,
      :email                 => email,
      :password              => "password",
      :password_confirmation => "password"
    )
  end
end

Given /^I sign in as "([^"]*)"$/ do |email_and_password|
  email, password = email_and_password.split('/')
  visit '/sign_in'
  fill_in 'Email',    :with => email
  fill_in 'Password', :with => password
  click_button 'Sign in'
end

Given /^I am signed in as an editor named "([^"]*)"$/ do |name|
  f, l = name.split(' ')
  p = Person.create(
    :first_name            => f,
    :last_name             => l,
    :email                 => "#{name.parameterize}@example.com",
    :password              => 'secret',
    :password_confirmation => 'secret'
  )
  Rank.create(
    :rank_type  => 3,
    :rank_start => Time.now,
    :person_id  => p.id
  )
  Given "I sign in as \"#{p.email}/secret\""
end
