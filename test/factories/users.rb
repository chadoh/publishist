# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.first_name "Thaddeus"
  f.last_name "Rutkowski"
  f.password "shidget"
  f.email "thadrut@gmail.com"
end
