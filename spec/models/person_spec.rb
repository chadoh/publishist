# encoding = UTF-8

require 'spec_helper'

describe Person do

  it {
    should belong_to(:primary_publication)
    should have_many(:attendees)
    should have_many(:meetings).through(:attendees)
    should validate_presence_of(:email)
    should have_many(:roles).dependent(:destroy)
    should have_many(:positions).through(:roles)
    should have_many(:position_abilities).through(:positions)
    should have_many(:abilities).through(:position_abilities)
  }

  describe "#issues" do
    it "returns issues for which I have some ability, and not those for which I don't" do
      ability = Ability.create key: 'scores', description: 'communicates things'
      mag1 = Issue.create title: 'first'
      mag2 = Issue.create title: 'second'
      pos1 = Position.create name:  'CoEditor', abilities: [ability], issue: mag1
      pos2 = Position.create name:  'Editor',   abilities: [ability], issue: mag1
      pos3 = Position.create name:  'Editor',   abilities: [ability], issue: mag2
      per1 = Person  .create name:  'sir roderick', email: 'roderick@example.com'
      pos1.people << per1
      pos2.people << per1
      per1.issues.should == [mag1]
    end
  end

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

  describe "#name" do
    let(:first_name) { "Tucker" }
    let(:middle_name) { "Adrian" }
    let(:last_name) { "Watts" }
    let(:email) { "tucker@gmale.com" }
    let(:person) { Person.new(attributes) }
    context "when they only have a first_name" do
      let(:attributes) { { first_name: first_name } }
      it "returns only that" do
        expect(person.name).to eq first_name
      end
    end
    context "when they only have a last_name" do
      let(:attributes) { { last_name: last_name } }
      it "returns only that" do
        expect(person.name).to eq last_name
      end
    end
    context "when they have a first, middle, & last name" do
      let(:attributes) { { first_name: first_name, middle_name: middle_name, last_name: last_name } }
      it "returns all three separated by spaces" do
        expect(person.name).to eq "#{first_name} #{middle_name} #{last_name}"
      end
    end
    context "when they have no name set" do
      let(:attributes) { { email: email } }
      it "returns their email address" do
        expect(person.name).to eq email
      end
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

    it "allows passing in additional params for the new user" do
      Person.any_instance.unstub(:primary_publication)
      publication = Factory.create :publication
      person = Person.find_or_create("Placebo Williams, pl@ce.bo", primary_publication: publication)
      expect(person.primary_publication).to eq(publication)
    end
  end

  context "permissions" do
    let!(:publication) { Factory.create :publication }
    let!(:person) { Factory.create :person, primary_publication: publication }
    let!(:issue) { Factory.create :issue, title: 'vast mental capabilities', publication: publication }
    let!(:position) { Factory.create :position, issue: issue, people: [person] }
    before do
      Person.any_instance.unstub(:primary_publication)
      Issue.any_instance.unstub(:publication)
      Submission.any_instance.unstub(:publication)
    end

    describe "#communicates?(resource, *flags)" do
      let(:ability) { Factory.create :ability, key: "communicates" }
      context "when resource.is_a Publication" do
        it "returns true if the person has the 'communicates' ability for any issue in the given publication" do
          position.abilities << ability
          person.communicates?(publication).should be_true
        end
        it "returns false if the person does not have the 'communicates' ability for any issue whatsoever" do
          person.communicates?(publication).should be_false
        end
        it "returns false if the person has the 'communicates' ability for a issue in a different publication" do
          publication2 = Factory.create(:publication)

          issue2 = Factory.create(:issue, publication: publication2)
          position2 = Factory.create(:position, issue: issue2)
          person.positions << position2

          position2.abilities << ability
          expect(person.communicates? publication).to be_false
        end
        context "and passed the :nowish flag" do
          it "returns false if the person has the 'communicates' ability for a issue that's no longer accepting submissions" do
            issue.update_attributes accepts_submissions_from: 3.weeks.ago, accepts_submissions_until: 2.week.ago
            position.abilities << ability
            person.communicates?(publication, :nowish).should be_false
          end
          it "returns true if the person has the 'communicates' ability for a issue that's still accepting submissions" do
            position.abilities << ability
            person.communicates?(publication, :nowish).should be_true
          end
          it "returns false if they have the 'communicates' ability for a current issue but a different publication" do
            publication2 = Factory.create(:publication)

            issue2 = Factory.create(:issue, publication: publication2)
            position2 = Factory.create(:position, issue: issue2, abilities: [ability])
            person.positions << position2

            position2.abilities << ability
            person.communicates?(publication, :nowish).should be_false
          end
        end
      end
      context "when resource.is_a Submission" do
        before do
          position.abilities << ability
        end
        it "returns false if the person does not have the 'communicates' ability for the given submission's issue" do
          issue = Issue.create publication: publication
          submission = Submission.create title: "<", body: "3", author: person, publication: publication, issue: issue
          person.communicates?(submission).should be_false
        end

        it "returns true if the person has the 'communicates' ability for the given submission's issue" do
          submission = Submission.create title: "<", body: "3", author: person, publication: publication, issue: issue
          person.communicates?(submission).should be_true
        end
      end
    end
    describe "#orchestrates?(resource)" do
      let(:ability) { Factory.create :ability, key: "orchestrates" }
      context "when passed a issue" do
        it "returns true if the person is in a position with the 'orchestrates' ability for the given issue" do
          position.abilities << ability
          person.orchestrates?(issue).should be_true
        end
        it "returns false if the person is in a position with the 'orchestrates' ability for a different issue" do
          issue2 = Issue.create publication: publication
          position2 = issue2.positions.create name: 'Smithy'
          person.positions << position2
          position2.abilities << ability
          person.orchestrates?(issue).should be_false
        end

        context "and also passed an :or_adjacent option" do
          before { position.abilities << ability }
          it "returns true if the person orchestrates the issue right before the one given" do
            later = Issue.create publication: publication
            person.orchestrates?(later, :or_adjacent).should be_true
          end
          it "returns true if the person orchestrates the issue right after the one given" do
            earlier = Issue.create(
              publication: publication,
              accepts_submissions_from:  issue.accepts_submissions_from - 6.months - 1.day,
              accepts_submissions_until: issue.accepts_submissions_from - 1.day
            )
            Issue.all.should == publication.issues
            person.orchestrates?(earlier, :or_adjacent).should be_true
          end
        end
      end

      context "when passed a meeting" do
        let(:meeting) { Factory.create :meeting, issue: issue }
        it "returns true if the person is in a position with the 'orchestrates' ability for the given meeting's issue" do
          position.abilities << ability
          person.orchestrates?(meeting).should be_true
        end
        it "returns false if the person is in a position with the 'orchestrates' ability for a different meeting's issue" do
          issue2 = Issue.create publication: publication
          position2 = issue2.positions.create name: 'Smithy'
          meeting2 = Factory.create :meeting, issue: issue2
          person.positions << position2
          position2.abilities << ability
          person.orchestrates?(meeting).should be_false
        end
      end

      context "when resource.is_a Publication" do
        it "returns true if the person has the 'orchestrates' ability for any issue in the given publication" do
          position.abilities << ability
          person.orchestrates?(publication).should be_true
        end
        it "returns false if the person does not have the 'orchestrates' ability for any issue whatsoever" do
          person.orchestrates?(publication).should be_false
        end
        it "returns false if the person has the 'orchestrates' ability for a issue in a different publication" do
          publication2 = Factory.create(:publication)

          issue2 = Factory.create(:issue, publication: publication2)
          position2 = Factory.create(:position, issue: issue2)
          person.positions << position2

          position2.abilities << ability
          expect(person.orchestrates? publication).to be_false
        end
        context "and passed the :nowish flag" do

          it "returns false if the person is in a position with the 'orchestrates' ability for a issue that no longer accepts submissions" do
            position.abilities << ability
            issue.update_attributes accepts_submissions_from: 2.weeks.ago, accepts_submissions_until: 1.week.ago
            person.orchestrates?(publication, :nowish).should be_false
          end
          it "returns true if the person is in a position with the 'orchestrates' ability for a issue that still accepts submissions" do
            position.abilities << ability
            person.orchestrates?(publication, :nowish).should be_true
          end
          it "returns false if they have the 'orchestrates' ability for a current issue but a different publication" do
            publication2 = Factory.create(:publication)

            issue2 = Factory.create(:issue, publication: publication2)
            position2 = Factory.create(:position, issue: issue2, abilities: [ability])
            person.positions << position2

            position2.abilities << ability
            person.communicates?(publication, :nowish).should be_false
          end
        end
      end
    end

    describe "#scores?(resource)" do
      let(:ability) { Factory.create :ability, key: "scores" }
      let(:meeting) { Factory.create :meeting, issue: issue }
      before { position.abilities << ability }

      it "returns true if the person is in a position with the 'orchestrates' ability for the given meeting's issue" do
        person.scores?(meeting).should be_true
      end
    end

    describe "#views?(resource, *flags)" do
      %w(views orchestrates scores communicates).each do |ability_key|
        let(:ability) { Factory.create :ability, key: ability_key }
        context "when resource.is_a Issue" do
          it "returns true when the person has #{ability_key} ability for that issue" do
            position.abilities << ability
            person.views?(issue).should be_true
          end
        end
        context "when resource.is_a Publication" do
          it "returns true if the person has the #{ability_key} ability for any issue in the given publication" do
            position.abilities << ability
            person.views?(publication).should be_true
          end
          it "returns false if the person does not have the #{ability_key} ability for any issue whatsoever" do
            person.views?(publication).should be_false
          end
          it "returns false if the person has the #{ability_key} ability for a issue in a different publication" do
            publication2 = Factory.create(:publication)

            issue2 = Factory.create(:issue, publication: publication2)
            position2 = Factory.create(:position, issue: issue2)
            person.positions << position2

            position2.abilities << ability
            expect(person.views? publication).to be_false
          end
        end
      end
    end
  end

end
