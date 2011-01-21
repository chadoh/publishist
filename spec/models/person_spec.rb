require 'spec_helper'

describe Person do

  it {
    should have_many(:attendees)
    should have_many(:meetings).through(:attendees)
    should validate_presence_of(:first_name)
  }

  describe "#name_and_email" do
    it "formats someone's name as 'first last <email@ddress>'" do
      person = Person.create(
        :first_name            => "Papa",
        :middle_name           => "Smurf",
        :email                 => "papa@smurf.me",
        :password              => "secret",
        :password_confirmation => "secret"
      )
      person.name_and_email.should == "Papa Smurf <email@ddress>"
    end
  end

  describe "#can_enter_scores_for?(meeting)" do
    let(:person)  { Factory.create :person }
    let(:meeting) { Factory.create :meeting }

    it "returns false if person didn't attend meeting" do
      person.can_enter_scores_for?(meeting).should be_false
    end

    context "when person attended the meeting," do
      before do
        @attendee = meeting.attendees.create :person => person
        submission = Factory.create :submission
        @packlet = meeting.packlets.create :submission => submission
      end

      it "returns true if person hasn't scored anything" do
        person.can_enter_scores_for?(meeting).should be_true
      end

      it "returns false if the coeditor scored for them" do
        @attendee.scores.create :amount => 5, :entered_by_coeditor => true, :packlet => @packlet
        person.can_enter_scores_for?(meeting).should be_false
      end

      it "returns true if person scored stuff and coeditor didn't" do
        @attendee.scores.create :amount => 5, :packlet => @packlet
        person.can_enter_scores_for?(meeting).should be_true
      end

      it "returns false if, somehow!, the person and the coeditor both entered scores" do
        submission = Factory.create :submission
        packlet_2   = meeting.packlets.create :submission => submission
        @attendee.scores.create :amount => 5, :packlet => @packlet, :packlet => packlet_2
        @attendee.scores.create :amount => 5, :entered_by_coeditor => true, :packlet => @packlet
        person.can_enter_scores_for?(meeting).should be_false
      end
    end
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
      pending "need to fork Devise and make confirmable work by setting password after receiving email" do
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

end
