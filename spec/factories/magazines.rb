# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :magazine do |f|
  f.name "MyString"
  f.abbreviated_name "MyString"
  f.accepts_submissions_from "2011-02-20 11:23:33"
  f.accepts_submissions_until "2011-02-20 11:23:33"
  f.published_on "2011-02-20 11:23:33"
end