# Read about factories at http://github.com/thoughtbot/factory_girl

Factory.define :editor, :class => Rank do |f|
  f.rank_type 3
  f.rank_start "2008-08-16 12:12:23"
  f.rank_end "2009-08-16 12:12:23"
  f.association :person
end

Factory.define :current_editor, :class => Rank do |f|
  f.rank_type 3
  f.rank_start "2008-08-16 12:12:23"
  f.association :person
end

Factory.define :coeditor, :class => Rank do |f|
  f.rank_type 2
  f.rank_start "2007-08-16 12:12:23"
  f.rank_end "2009-08-16 12:12:23"
  f.association :person
end

Factory.define :current_coeditor, :class => Rank do |f|
  f.rank_type 2
  f.rank_start "2007-08-16 12:12:23"
  f.association :person
end

Factory.define :staff, :class => Rank do |f|
  f.rank_type 1
  f.rank_start "2006-08-16 12:12:23"
  f.rank_end "2009-08-16 12:12:23"
  f.association :person
end

Factory.define :current_staff, :class => Rank do |f|
  f.rank_type 1
  f.rank_start "2006-08-16 12:12:23"
  f.association :person
end
