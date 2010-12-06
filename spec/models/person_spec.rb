require 'spec_helper'

describe Person do

  it {
    should have_many(:attendances)
    should have_many(:meetings).through(:attendances)
    should validate_presence_of(:first_name)
  }

  it "creates a new account with a hashed_password and salt if a password is provided" do
    @person = Person.create(
      :first_name => "weazle",
      :email => "simmers@jimmers.ru",
      :password => "secrets",
      :password_confirmation => "secrets"
    )
    @person.should be_valid
    @person.salt.should_not be_blank
    @person.salt.should_not == "n00b"
    @person.encrypted_password.should_not be_blank
    @person.verified.should be_true
  end

  it "creates a new account with no hashed_password and a salt of 'n00b' if no password is provided" do
    @person = Person.create(
      :first_name => "weazle",
      :email => "simmers@jimmers.ru"
    )
    @person.should be_valid
    @person.encrypted_password.should be_blank
    @person.salt.should == "n00b"
    @person.verified.should_not be_true
  end

  describe "self.find_or_create" do
    it "finds a person when formatted as '(anything) <persons@email.address>" do
      @person = Factory.create :person
      Person.find_or_create(":-D <#{@person.email}>").should == @person
    end

    it "returns nil if no email address is given" do
      bads = ['"Chad Ostrowski"', 'stephen']
      bads.each do |bad|
        person = Person.find_or_create bad
        person.should be_nil
      end
    end

    it "returns nil if an email address is given with no name" do
      bads = ['<chad.ostrowski@gmail.com>', 'tulip@me.you']
      bads.each do |bad|
        person = Person.find_or_create bad
        person.should be_nil
      end
    end

    it "creates a new person if formatted as '(\")some text(\") <email@ddress.com>'" do
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

        person.should_not be_nil
        person.should_not be_verified
        person.first_name.should == new[1]
        person.middle_name.to_s.should == new[3]
        person.last_name.to_s.should == new[5]
      end
    end
  end

end
