Then /print page\.html/ do
  print page.html
end

Then /^p (.*)$/ do |object|
  p eval(object)
end
