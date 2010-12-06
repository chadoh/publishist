# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :session do |f|
  f.ip_address "10.123.37.1"
  f.path "/compositions/new"
  f.association :person
end
