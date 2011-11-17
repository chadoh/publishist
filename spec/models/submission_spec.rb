require 'spec_helper'

describe Submission do
  it {
    should have_many(:packlets).dependent(:destroy)
    should have_many(:meetings).through(:packlets)
    should have_many(:scores).through(:packlets)
    should belong_to :author
    should belong_to :page
    should belong_to :magazine
  }

  describe "#title" do
    it "cannot be more than 255 characters" do
      sub = Submission.new title: 'x'*256, body: 'oooh, yeah.', author_email: "bob@example.com"
      sub.should have(1).error_on(:title)
      sub.title = 'x'*255
      sub.should be_valid
    end
  end

  it "sets queued submissions to reviewed if their meeting is less than three hours in the future" do
    meeting = Factory.create :meeting
    submission = Factory.create :submission
    meeting.submissions << submission
    meeting.update_attribute :datetime, 2.hours.from_now
    submission.reload.should be_reviewed
    submission.update_attribute :state, Submission.state(:queued)
    submission.should be_queued
    submission.reload.should be_reviewed
  end

  describe "#author_has_positions_with_the_disappears_ability" do
    before do
      @ab  = Ability.create key: 'disappears', description: "Submitters & attendees are automatically added to this group. It will disappear once the magazine is published."
      @pos = Magazine.create.positions.create name: "The Folks", abilities: [@ab]
      @per = Person.create name: "Baxter", email: 'example@example.com'
      @sub = @per.submissions.create title: "marblecake", body: "also, the game"
    end
    it "puts the submitter into all positions that have the 'disappears' ability upon creation" do
      @per.positions.should be_present
      @per.positions.first.should == @pos
    end
    it "just ignores the whole business on future submissions" do
      @pos.reload
      sub2 = @per.submissions.create title: "the game", body: "also, marblecake"
      Submission.last.should == sub2.reload
    end
  end

  describe "#has_been" do
    it "moves the sumbission into the specified state" do
      sub = Factory.build :submission
      sub.has_been :reviewed
      sub.state.should == :reviewed
    end

    context "when submitting" do
      it "sends an email to the editor, by default" do
        sub = Factory.create :submission
        mock_mail = mock(:mail)
        mock_mail.stub(:deliver)
        Notifications.should_receive(:new_submission).with(sub).and_return(mock_mail)
        sub.has_been :submitted
      end

      it "sends no email, if it was submitted by the editor" do
        sub = Factory.create :submission
        Person.should_receive(:current_communicators).and_return(["Blimey, Tim!"])
        Notifications.should_not_receive(:new_submission)
        sub.has_been :submitted, :by => "Blimey, Tim!"
      end
    end
  end

  context "when updating the state" do
    context "to :submitted" do
      it "sends a notification if state was :draft" do
        sub = Submission.create title: "love", body: "&loss", author: Factory.create(:person), state: :draft

        mock_mail = mock(:mail)
        mock_mail.stub(:deliver)
        Notifications.should_receive(:new_submission).with(sub).and_return(mock_mail)

        sub.update_attributes state: :submitted
      end
      it "sends a notification if a new submission" do
        sub = Submission.new title: "love", body: "&loss", author: Factory.create(:person), state: :submitted

        mock_mail = mock(:mail)
        mock_mail.stub(:deliver)
        Notifications.should_receive(:new_submission).with(sub).and_return(mock_mail)

        sub.save
      end
      it "does not send a notification if state was :reviewed" do
        sub = Submission.create title: "love", body: "&loss", author: Factory.create(:person), state: :reviewed

        Notifications.should_not_receive(:new_submission)

        sub.update_attributes state: :submitted
      end
      it "does not send a notification if was :draft, but is being updated by the person who would get the email" do
        per = Factory.create(:person)
        sub = Submission.create title: "love", body: "&loss", author: per, state: :draft

        Person.should_receive(:current_communicators).and_return([per])
        Notifications.should_not_receive(:new_submission)

        sub.update_attributes state: :submitted, updated_by: per
      end
    end
  end

  describe "#position" do
    it "defaults to nil" do
      sub = Submission.create title: 'boring', body: 'poem', author_email: "no@example.com"
      sub.reload.position.should be_nil
    end
  end

  context "has methods to check if in a certain state:" do
    before :each do
      @sub = Submission.create :title => "Cheese",
                               :body => "Whiz",
                               :author => Factory.create(:person)
    end

    it "has a #draft? method" do
      (@sub.draft?).should be_true
    end

    it "has a #submitted? method" do
      (@sub.submitted?).should be_false
    end
  end

  it "sets the state to 'published' if the magazine has already been published" do
    mag = Magazine.create(
      accepts_submissions_from:  6.months.ago,
      accepts_submissions_until: Date.yesterday,
      title: "Gone"
    )
    mag.publish []
    sub = Factory.create :submission, magazine: mag
    sub.reload.state.should == :published
    sub.page.to_s.should == '1'
  end

  it "removes the page and the position when being rejected" do
    sub = Factory.create :submission
    mag = Magazine.create(
      accepts_submissions_from:  6.months.ago,
      accepts_submissions_until: Date.yesterday,
      title: "Gone"
    )
    mag.publish [sub]
    sub.reload.state.should == :published
    sub.page.to_s.should == '1'
    sub.position.should == 1
    sub.update_attributes state: :rejected
    sub.reload.state.should == :rejected
    sub.page.should be_nil
    sub.position.should be_nil
  end

  it "sets the author_name field to 'anonymous' if there is no associated author" do
    sub = Submission.create :title => "some ugly cat", :author_email => "non@one.me"
    sub.author_name.should == "Anonymous"
  end

  it "verifies that there is either an associated author or an author_email" do
    sub = Submission.new :title => "Marvin eats an ice cream cone"
    sub.should_not be_valid

    sub.author_email = "marvin@gmail.mars"
    sub.should be_valid

    sub.author_email = nil
    sub.author = Factory.create :person
    sub.should be_valid
  end

  it "verifies that there is either a title or a body" do
    sub = Submission.new :author_email => "samwell@gamgee.net"
    sub.should_not be_valid

    sub.title = "Who, me?"
    sub.should be_valid

    sub.title = nil
    sub.body = "But of course!"
    sub.should be_valid
  end

  describe "#pseudonym" do
    it "retrieves an associated pseudonym, if there is one" do
      person = Person.create name: 'Miriam Webster', email: 'example@example.com'
      @sub = Submission.create(
        :title  => ';-)',
        :body   => 'he winks and smiles <br><br> both',
        :author => person
      )
      pseud = Pseudonym.create name: "Cheese Winkle", submission_id: @sub.id
      @sub.pseudonym.should == pseud
    end
  end
  describe "#pseudonym_name" do
    it "retrieves an associated pseudonym's name (if there is one)" do
      sub = Factory.create :submission, pseudonym_name: "Pablo Honey"
      sub.pseudonym_name.should == "Pablo Honey"
    end
  end
  describe "#pseudonym_link" do
    it "retrievs an associaoted pseudonym's :link_to_profile (if there is one)" do
      sub = Factory.create :submission, pseudonym_name: "Pablo Honey"
      sub.pseudonym_link.should == true
    end
  end
  describe "pseudonym_name=(a_string)" do
    it "creates a pseudonym with the given string as the name" do
      person = Person.create name: 'Miriam Webster', email: 'example@example.com'
      @sub = Submission.create(
        title: ';-)',
        body: 'he winks and smiles <br><br> both',
        author: person,
        pseudonym_name: "Merry Winkle"
      )
      @sub.reload.pseudonym.should == Pseudonym.first
    end
    it "updates an already-existent pseudonym with the new name" do
      person = Person.create name: 'Miriam Webster', email: 'example@example.com'
      @sub = Submission.create(
        title: ';-)',
        body: 'he winks and smiles <br><br> both',
        author: person,
        pseudonym_name: "Merry Winkle"
      )
      pseud1 = @sub.pseudonym
      @sub.pseudonym_name = "Bratty Winkle"
      @sub.pseudonym.reload.name.should == "Bratty Winkle"
      @sub.pseudonym.id.should == pseud1.id
    end
  end
  describe "#pseudonym_link=(a_boolean)" do
    it "does not create a pseudonym if one doesn't exist already" do
      @sub = Factory.create :submission, pseudonym_link: false
      @sub.pseudonym.should be_nil
    end
    it "sets the link_to_profile for an associated pseudonym" do
      @sub = Factory.create :submission, pseudonym_name: "PHC", pseudonym_link: false
      @sub.pseudonym.link_to_profile.should be_false
    end
  end

  describe "#author_name" do
    it "returns the author_name field if there is no associated author" do
      @sub = Submission.create(
        :title => ';-)',
        :body => 'he winks and smiles <br><br> both',
        :author_email => 'me@you.com',
        :author_name => "Smeagul Rabbit"
      )
      @sub.author_name.should == "Smeagul Rabbit"
    end

    it "returns the associated author's name if there is an associated author" do
      person = Person.create name: 'Miriam Webster', email: 'example@example.com'
      @sub = Submission.create(
        :title  => ';-)',
        :body   => 'he winks and smiles <br><br> both',
        :author => person
      )
      @sub.author_name.should == person.name
    end

    it "returns the pseudonym if there is one" do
      person = Person.create name: 'Miriam Webster', email: 'example@example.com'
      @sub = Submission.create(
        title:     ';-)',
        body:      'he winks and smiles <br><br> both',
        author:    person,
        pseudonym_name: 'St. Nicolai'
      )
      @sub.author_name.should == "St. Nicolai"
    end

    it "does not return the pseudonym if it is an empty string" do
      person = Person.create name: 'Miriam Webster', email: 'example@example.com'
      @sub = Submission.create(
        title:          ';-)',
        body:           'he winks and smiles <br><br> both',
        author:         person,
        pseudonym_name: ''
      )
      @sub.author_name.should == person.name
    end
  end

  describe "#average_score" do
    before :each do
      @magazine = Factory.create :magazine
      @meeting = @magazine.meetings.create datetime: Time.now
      @submission = Factory.create :submission
      @person = Factory.create :person
      @person2 = Factory.create :person

      @meeting.people = [@person, @person2]
      @meeting.update_attributes :magazine => @magazine
      @packlet = @meeting.packlets.create :submission => @submission

      @packlet.scores.create :attendee => @meeting.attendees.first, :amount => 4
      @packlet.scores.create :attendee => @meeting.attendees.last , :amount => 6
    end

    it "returns the average score for the submission" do
      @submission.average_score.should == 5
    end

    it "returns the average score even if the submission was reviewed at multiple meetings" do
      meeting = Factory.create :meeting
      meeting.people = [@person, @person2]
      meeting.update_attributes :magazine => @magazine
      @packlet = meeting.packlets.create :submission => @submission

      @packlet.scores.create :attendee => meeting.attendees.first, :amount => 8
      @packlet.scores.create :attendee => meeting.attendees.last , :amount => 6
      @submission.average_score.should == 6
    end
  end

  describe "#destroy" do
    it "destroys associated pseudonym (if there is one)" do
      @sub = Factory.create :submission, pseudonym_name: "Pablo Honey"
      @sub.destroy
      Pseudonym.count.should == 0
    end
  end

  describe "#magazine" do
    it "defaults to the current magazine" do
      mg1 = Factory.build :magazine
      mg2 = Factory.build :magazine
      Magazine.stub(:current).and_return(mg1)
      sub = Submission.new
      sub.magazine.should == mg1
    end
    it "does not override the magazine if it's already set" do
      mg1 = Factory.create :magazine
      mg2 = Factory.create :magazine
      sub = Submission.create title: "margeret", body: "tatcher", author_email: "ex@mple.com", magazine: mg1
      Magazine.stub(:current).and_return(mg2)
      sub.reload.magazine.should == mg1
    end
  end

  describe "self.published" do
    it "returns only published submissions" do
      s1 = Factory.create :submission, state: Submission.state(:published)
      s2 = Factory.create :submission, state: Submission.state(:rejected)
      Submission.published.should == [s1]
    end
  end

end
