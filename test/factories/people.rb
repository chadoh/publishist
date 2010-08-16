# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :person do |f|
  f.first_name "Chad"
  f.middle_name "Anthony"
  f.last_name "Ostrowski"
  f.email "chad@chadoh.com"
  f.salt "some_salt"
  f.encrypted_password "some_encryption"
end
