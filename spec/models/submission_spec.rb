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
