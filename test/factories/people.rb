# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :person do |f|
  f.first_name "Chad"
  f.middle_name "Anthony"
  f.last_name "Ostrowski"
  f.email "chad@chadoh.com"
  f.password "secret"
  f.password_confirmation "secret"
end

Factory.define :person2, :class => Person do |f|
  f.first_name "Chad"
  f.middle_name "Anthony"
  f.last_name "Ostrowski"
  f.email "screetch@chadoh.com"
  f.password "secret"
  f.password_confirmation "secret"
end

Factory.define :person3, :class => Person do |f|
  f.first_name "Chad"
  f.middle_name "Anthony"
  f.last_name "Ostrowski"
  f.email "krumpit@chadoh.com"
  f.password "secret"
  f.password_confirmation "secret"
end
