# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :person do |f|
  f.first_name "MyString"
  f.middle_name "MyString"
  f.last_name "MyString"
  f.email "MyString"
  f.salt "MyString"
  f.encrypted_password "MyString"
end
