Then /save and open page/ do
  save_and_open_page
end

Then /^p (.*)$/ do |object|
  p eval(object)
end
