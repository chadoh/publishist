require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  setup do
    @person = Factory(:person)
  end

  should have_many(:attendances)
  should have_many(:meetings).through(:attendances)

  should "create a new account with a hashed_password and salt IF a password is provided" do
    @person = Person.new(
      :first_name => "weazle",
      :email => "simmers@jimmers.ru",
      :password => "secrets",
      :password_confirmation => "secrets"
    )
    assert @person.valid?
    assert !@person.salt.blank?
    assert_not_equal @person.salt, "n00b"
    assert !@person.encrypted_password.blank?
    assert @person.verified
  end

  should "create a new account with no hashed_password and a salt of 'n00b' if NO password is provided" do
    @person = Person.new(
      :first_name => "weazle",
      :email => "simmers@jimmers.ru"
    )
    @person.save
    assert @person.valid?
    assert @person.encrypted_password.blank?
    assert_equal @person.salt, "n00b"
    assert !@person.verified
  end

  should "require first_name to be set" do
    @person = Person.new( :first_name => "Thad",
      :email                 => "th@d.com",
      :password              => "secret",
      :password_confirmation => "secret"
    )
    assert @person.valid?
  end

  context "ranks: when making a new person" do
    should "not give people any rank" do
      @person2 = Factory(:person2)
      assert_equal @person2.ranks.count, 0
    end
  end

  context "find_or_create" do
    should "return errors if not formatted as \"first_name middle_name last_name\" <email@ddres.com>" do
      finds = Person.all
      finds.each do |find|
        person = Person.find_or_create("\"#{find.first_name}\" <#{find.email}>")
        assert_equal person, find
      end

      bads = ['"Chad Ostrowski"', '<chad.ostrowski@gmail.com>', 'stephen']
      bads.each do |bad|
        person = Person.find_or_create bad
        assert_equal person.errors.count, 1
      end

      news = [
        ['"', 'Steven', ' ', ''                      , '' , 'Dunlop' , '" <stephen.dunlop@gmail.com>'],
        ['"', 'Marvin', ' ', 'the'                   , ' ', 'Martian', '" <marvin@yes.mars>'],
        ['"', 'Wendy' , ' ', 'with many middle names', ' ', 'Yoder'  , '" <walace.yoder@gmail.com>'],
        ['' , 'No'    , ' ', 'quotes'                , ' ', 'here!'  , '  <whatchagonedo@bout.it>'],
        ['' , 'Máça'  , ' ', ''                      , '' , 'Fascia' , '  <desli@yiis.net>'],
        ['' , 'Morgan', ' ', ''                      , '' , ''       , '  <morgan@yes.gov>']
      ]
      news.each do |new|
        person = Person.find_or_create new.join('')
        assert Person.find_by_email person.email
        assert_equal person.verified, false
        assert_equal person.first_name, new[1]
        if new[3].blank?
          assert_equal person.middle_name, nil
        else
          assert_equal person.middle_name, new[3]
        end
        if new[5].blank?
          assert_equal person.last_name, nil
        else
          assert_equal person.last_name, new[5]
        end
      end
    end
  end
end
