# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

Person.create(
  :first_name            => 'Chad',
  :middle_name           => 'Anthony Eric',
  :last_name             => 'Ostrowski',
  :email                 => 'chad.ostrowski@gmail.com',
  :password              => 'bubbles',
  :password_confirmation => 'bubbles')

Person.create(
  :first_name            => 'Swati',
  :middle_name           => '',
  :last_name             => 'Prasad',
  :email                 => 'lookitsswati@gmail.com',
  :password              => 'bubbles',
  :password_confirmation => 'bubbles')

Person.create(
  :first_name            => 'Jim',
  :middle_name           => 'Robert',
  :last_name             => 'Rose',
  :email                 => 'jrose835@gmail.com',
  :password              => 'bubbles',
  :password_confirmation => 'bubbles')

Rank.create(
  :person_id => 2,
  :rank_type => 3)

Rank.create(
  :person_id => 3,
  :rank_type => 2)

Meeting.create(
  :when     => Time.now + 1.week,
  :question => "What aspect of the plentiful imagery of the world are *you*?")
