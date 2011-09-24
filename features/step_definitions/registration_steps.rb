When /^I pass the CAPTCHA$/ do
  Rack::Recaptcha.test_mode! return: true
end

When /^I fail the CAPTCHA$/ do
  Rack::Recaptcha.test_mode! return: false
end

Then /^my submission should still be filled in$/ do
  ['Title', 'Body', 'Your Name', 'Your Email Address'].each do |field|
    find_field(field).value.should_not be_blank
  end
end

Then /^all my information should still be filled out in the form$/ do
  ['Name', 'Email'].each do |field|
    find_field(field).value.should_not be_blank
  end
end
