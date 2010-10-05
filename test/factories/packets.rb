# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :packet do |f|
  f.association :meeting
  f.association :poetry_submission
  f.position 1
end

Factory.define :packet2, :class => Packet do |f|
  f.association :meeting
  f.association :anonymous_poetry_submission
  f.position 2
end
