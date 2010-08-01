# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :user do |f|
  f.name "MyString"
  f.email "MyString"
  f.hashed_password "MyString"
  f.salt "MyString"
end
