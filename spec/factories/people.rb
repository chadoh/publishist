Factory.define :person do |f|
  f.first_name "Chad"
  f.middle_name "Anthony"
  f.last_name "Ostrowski"
  f.sequence(:email) {|n| "chad#{n}@chadoh.com" }
  f.password "secret"
  f.password_confirmation "secret"
end
