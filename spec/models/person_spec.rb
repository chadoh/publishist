# encoding = UTF-8

require 'spec_helper'

describe Person do

  it {
    should have_many(:attendees)
    should have_many(:meetings).through(:attendees)
    should validate_presence_of(:first_name)
    should have_many(:roles).dependent(:destroy)
    should have_many(:positions).through(:roles)
    should have_many(:abilities).through(:positions)
  }

  describe "#name_and_email" do
    it "formats someone's name as 'first last, email@ddress'" do
      person = Person.create(
        :first_name            => "Papa",
        :last_name             => "Smurf",
        :email                 => "papa@smurf.me",
        :password              => "secret",
        :password_confirmation => "secret"
      )
      person.name_and_email.should == "Papa Smurf, papa@smurf.me"
    end
  end

  describe "#name=" do
    let(:person){ Person.new }
    it "sets a first name, if only one word is provided" do
      person.name = 'Wes'
      person.first_name.should == 'Wes'
    end
    it "sets a first name and a last name, if two words are provided" do
      person.name = "Wes Anderson"
      person.first_name.should == 'Wes'
      person.last_name.should == 'Anderson'
    end
    it "sets a first, middle, and last name if 3 words are provided" do
      person.name = 'Wes Neo Anderson'
      person.first_name.should == 'Wes'
      person.middle_name.should == 'Neo'
      person.last_name.should == 'Anderson'
    end
    it "sets the middle name to _all_ the middle names, if >3 words are provided" do
      person.name = "Wes Thomas A. 'Neo' Anderson"
      person.first_name.should == 'Wes'
      person.middle_name.should == "Thomas A. 'Neo'"
      person.last_name.should == 'Anderson'
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
    it "finds a person when formatted as '(anything), persons@email.address" do
      @person = Factory.create :person
      Person.find_or_create(":-D, #{@person.email}").should == @person
    end

    it "finds a person even if formatted with a person's email address only" do
      @person = Factory.create :person
      Person.find_or_create("#{@person.email}").should == @person
    end

    it "returns false if no email address is given" do
      bads = ['"Chad Ostrowski"', 'stephen', '']
      bads.each do |bad|
        person = Person.find_or_create bad
        person.should be_false
      end
    end

    it "returns nil if an email address is given with no name" do
      bads = ['<chad.ostrowski@gmail.com>', 'tulip@me.you']
      bads.each do |bad|
        person = Person.find_or_create bad
        person.should be_nil
      end
    end

    it "creates a new person if formatted as '(\")some text(\"), email@ddress.com'" do
      news = [
        ['"', 'Steven', ' ', ''                      , '' , 'Dunlop' , '," ', 'stephen.dunlop@gmail.com'],
        ['"', 'Marvin', ' ', 'the'                   , ' ', 'Martian', '," ', 'marvin@yes.mars'],
        ['"', 'Wendy' , ' ', 'with many middle names', ' ', 'Yoder'  , '," ', 'walace.yoder@gmail.com'],
        ['' , 'No'    , ' ', 'quotes'                , ' ', 'here!'  , ',  ', 'whatchagonedo@bout.it'],
        ['' , 'Máça'  , ' ', ''                      , '' , 'Fascia' , ',  ', 'desli@yiis.net'],
        ['' , 'Morgan', '' , ''                      , '' , ''       , ',  ', 'morgan@yes.gov']
      ]
      news.each do |new|
        person = Person.find_or_create new.join('')

        person.should_not be_nil
        person.should_not be_confirmed
        person.first_name.should == new[1]
        person.middle_name.to_s.should == new[3]
        person.last_name.to_s.should == new[5]
        person.email.to_s.should == new[7]
      end
    end
  end

  context "permissions" do
    describe "#orchestrates?(resource)" do
      before do
        @ability  = Ability.create key: 'orchestrates', description: "Can organize meetings, record attendance, publish magazines, and specify staff."
        @person   = Person.create name: "Francisco Ferdinand", email: 'example@example.com'
      end
      context "when passed a magazine" do
        before do
          @magazine = Magazine.create
          @position = @magazine.positions.create name: 'Pirate'
          @person.positions << @position
        end
        it "returns true if the person is in a position with the 'orchestrates' ability for the given magazine" do
          @position.abilities << @ability
          @person.orchestrates?(@magazine).should be_true
        end
        it "returns false if the person is in a position with the 'orchestrates' ability for a different magazine" do
          mag2 = Magazine.create
          position2 = mag2.positions.create name: 'Smithy'
          @person.positions << position2
          position2.abilities << @ability
          @person.orchestrates?(@magazine).should be_false
        end
      end

      context "when passed a meeting" do
        before do
          @magazine = Magazine.create
          @meeting = @magazine.meetings.create question: 'Is this all there is?', datetime: Time.now
          @position = @magazine.positions.create name: 'Pirate'
          @person.positions << @position
        end
        it "returns true if the person is in a position with the 'orchestrates' ability for the given meeting's magazine" do
          @position.abilities << @ability
          @person.orchestrates?(@meeting).should be_true
        end
        it "returns false if the person is in a position with the 'orchestrates' ability for a different meeting's magazine" do
          mag2      = Magazine.create
          position2 = mag2.positions.create name: 'Smithy'
          @person.positions   << position2
          meeting2  = mag2.meetings.create question: 'Is this all there is?', datetime: Time.now
          position2.abilities << @ability
          @person.orchestrates?(@meeting).should be_false
        end
      end

      context "when passed :currently or :now" do
        before do
          @magazine = Magazine.create(
            accepts_submissions_from:  6.months.ago,
            accepts_submissions_until: 1.month.ago,
            title:                     'peaches'
          )
          @position = @magazine.positions.create name: 'Mage'
          @position.abilities << @ability
          @person.positions << @position
        end

        it "returns false if the person is in a position with the 'orchestrates' ability for a magazine that no longer accepts submissions" do
          @person.orchestrates?(:currently).should be_false
        end

        it "returns true if the person is in a position with the 'orchestrates' ability for a magazine that still accepts submissions" do
          mag2 = Magazine.create(accepts_submissions_until: 1.month.from_now)
          pos2 = mag2.positions.create name: 'Sheepheard'
          pos2.abilities << @ability
          @person.positions << pos2
          @person.orchestrates?(:currently).should be_true
        end
      end
      context "when passed :any" do
        before do
          @magazine = Magazine.create(
            accepts_submissions_from:  6.months.ago,
            accepts_submissions_until: 1.month.ago,
            title:                     'peaches'
          )
          @position = @magazine.positions.create name: 'Mage'
          @position.abilities << @ability
        end
        it "returns true if the person is in a position with the 'orchestrates' ability for any magazine" do
          @person.positions << @position
          @person.orchestrates?(:any).should be_true
        end
        it "returns false if the person has no 'orchestrates' abilities whatsoever" do
          @person.orchestrates?(:any).should be_false
        end
      end
    end

    describe "#scores?(resource)" do
      before do
        @ability  = Ability.create key: 'scores', description: "Scores stuff"
        @person   = Person.create name: "Francisco Ferdinand", email: 'example@example.com'
        @magazine = Magazine.create
        @meeting = @magazine.meetings.create question: 'Is this all there is?', datetime: Time.now
        @position = @magazine.positions.create name: 'Pirate'
        @position.abilities << @ability
        @person.positions << @position
      end
      it "returns true if the person is in a position with the 'orchestrates' ability for the given meeting's magazine" do
        @person.scores?(@meeting).should be_true
      end
      it "returns false if the person has another ability (but not 'scores') for the meeting's magazine" do
        @ability.update_attribute :key, 'edits'
        @person.scores?(@meeting).should be_false
      end
    end

    describe "#views?(resource)" do
      context "when resource.is_a Magazine" do
        it "returns true when the person has the 'orchestrates' or the 'views' ability for the given magazine" do
          @ability   = Ability.create key: 'orchestrates', description: "Orchestrates stuff"
          @ability2  = Ability.create key: 'views', description: "orchestrates stuff"
          @person    = Person.create name: "Francisco Ferdinand", email: 'example@example.com'
          @person2   = Person.create name: "Ferdinand Francisco", email: 'example2@example.com'
          @magazine  = Magazine.create
          @position  = @magazine.positions.create name: 'Corporal'
          @position2 = @magazine.positions.create name: 'Mate'
          @position.abilities << @ability
          @position2.abilities << @ability2
          @person.positions << @position
          @person2.positions << @position2
          @person.views?(@magazine).should be_true
          @person2.views?(@magazine).should be_true
        end
      end
      context "when resource == :any" do
        it "returns true when the person has any associated positions with an 'orchestrates' ability" do
          @ability  = Ability.create key: 'orchestrates', description: "Orchestrates stuff"
          @person   = Person.create name: "Francisco Ferdinand", email: 'example@example.com'
          @magazine = Magazine.create
          @position = @magazine.positions.create name: 'Corporal'
          @position.abilities << @ability
          @person.positions << @position
          @person.views?(:any).should be_true
        end
        it "returns true when the person has any associated positions with a 'views' ability" do
          @ability  = Ability.create key: 'views', description: "Views stuff"
          @person   = Person.create name: "Francisco Ferdinand", email: 'example@example.com'
          @magazine = Magazine.create
          @position = @magazine.positions.create name: 'Admiral'
          @position.abilities << @ability
          @person.positions << @position
          @person.views?(:any).should be_true
        end
      end
    end
  end

end
