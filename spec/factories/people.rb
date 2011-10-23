Factory.define :person do |f|
  f.first_name "Julia"
  f.middle_name "Ellie"
  f.last_name "Quinn"
  f.sequence(:email) {|n| "julia#{n}@example.com" }
  f.password "secret"
  f.password_confirmation "secret"
  f.confirmed_at Time.now
end
