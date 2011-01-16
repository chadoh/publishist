# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :attendee do |f|
  f.association :meeting
  f.association :person, :factory => :person2
  f.answer "MyString"
end
