# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :meeting do |f|
  f.when "2010-09-10 07:44:06"
  f.question "MyString"
end
