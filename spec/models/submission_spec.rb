require 'spec_helper'

describe Submission do
  let(:editor) { double("editor", email: "woo@woo.woo").as_null_object }
  let(:issue) { Factory.create :issue }
  let(:publication) { double("publication", editor: editor, current_issue!: issue, current_issue: issue).as_null_object }
  before { Submission.any_instance.stub(:publication).and_return(publication) }
  it {
    should have_many(:packlets).dependent(:destroy)
    should have_many(:meetings).through(:packlets)
    should have_many(:scores).through(:packlets)
    should belong_to :author
    should belong_to :page
    should belong_to :issue
    should belong_to :publication
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
      @ab  = Ability.create key: 'disappears', description: "Submitters & attendees are automatically added to this group. It will disappear once the issue is published."
      @pos = Issue.create.positions.create name: "The Folks", abilities: [@ab]
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
      context "when submitted by the editor" do
        let(:publication) { Factory.create :publication }
        it "sends no email, if it was submitted by the editor" do
          sub = Factory.create :submission, state: :draft, publication: publication
          publication.should_receive(:editor).and_return("Blimey, Tim!")
          Notifications.should_not_receive(:new_submission)
          sub.has_been :submitted, :by => "Blimey, Tim!"
        end
      end

      context "when submitted by anyone else" do
        it "sends an email to the editor, by default" do
          sub = Factory.create :submission, state: :draft
          mock_mail = mock(:mail)
          mock_mail.stub(:deliver)
          Notifications.should_receive(:new_submission).with(sub).and_return(mock_mail)
          sub.has_been :submitted
        end
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
    end
  end

  describe "#position" do
    it "defaults to nil" do
      sub = Factory.create :submission
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

  context "when submitting for a issue that has already been published" do
    it "sets the state to 'published' if changed to a issue that has already been published" do
      issue = Issue.create(
        accepts_submissions_from:  6.months.ago,
        accepts_submissions_until: Date.yesterday,
        title: "Gone"
      )
      issue.publish []
      sub = Factory.create :submission, issue: issue
      sub.reload.should be_published
      sub.page.to_s.should == '1'
    end

    it "does not set the state to 'published' if the submission had already been for this issue" do
      issue = Issue.create(
        accepts_submissions_from:  6.months.ago,
        accepts_submissions_until: Date.yesterday,
        title: "Gone"
      )
      sub = Factory.create :submission, issue: issue
      issue.publish []
      sub.reload.should be_rejected
      sub.save
      sub.should be_rejected
      sub.page.should be_nil
      sub.position.should be_nil
    end
  end

  it "sets the page and position if the submission is published" do
    issue = Issue.create(
      accepts_submissions_from:  6.months.ago,
      accepts_submissions_until: Date.yesterday,
      title: "Gone"
    )
    issue.publish []
    sub = Factory.create :submission, issue: issue
    sub.update_attributes page: nil, position: nil
    sub.page.should_not be_nil
    sub.position.should_not be_nil
  end

  it "does not override page and position if already set" do
    issue = Issue.create(
      accepts_submissions_from:  6.months.ago,
      accepts_submissions_until: Date.yesterday,
      title: "Gone"
    )
    issue.publish []
    sub = Factory.create :submission, issue: issue
    page = issue.pages.create
    sub.page = page
    sub.save
    sub.page.should == page
  end

  it "removes the page when being rejected" do
    issue = Issue.create(
      accepts_submissions_from:  6.months.ago,
      accepts_submissions_until: Date.yesterday,
      title: "Gone"
    )
    sub = Factory.create :submission, issue: issue
    issue.publish [sub]
    sub.reload.state.should == :published
    sub.page.to_s.should == '1'
    sub.position.should == 1
    sub.update_attributes state: :rejected
    sub.reload.state.should == :rejected
    sub.page.should be_nil
    #sub.position.should be_nil
  end

  it "verifies that there is an associated author" do
    sub = Submission.new :title => "Marvin eats an ice cream cone"
    sub.should_not be_valid

    sub.author = Factory.create :person
    sub.should be_valid
  end

  it "verifies that there is either a title or a body" do
    sub = Submission.new author: Factory.create(:person)
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
    it "defaults to 'true' if there is no pseudonym yet" do
      sub = Factory.create :submission
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
    it "does not cause problems when updating a submission with no pseudonym" do
      sub = Factory.create :submission, pseudonym_name: ""
      sub.pseudonym.should be_nil
      Pseudonym.count.should == 0
      sub.update_attributes title: "haheho", pseudonym_name: ""
      sub.title.should == "haheho"
      sub.pseudonym.should be_nil
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
    it "overrides the link_to_profile for an associated pseudonym, if the submission is being updated" do
      sub = Factory.create :submission, pseudonym_name: "PHC"
      sub.update_attributes pseudonym_link: false
      sub.reload.pseudonym_link.should be_false
    end
  end

  describe "#author_name" do
    it "returns blank, if there is no associated author (for new submissions)" do
      @sub = Submission.new
      @sub.author_name.should == ''
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

  describe "#author_email" do
    it "returns the associated author's email" do
      sub = Factory.create :submission
      person = sub.author
      sub.author_email.should == person.email
    end
    it "returns blank if there's no associated author (a new submission)" do
      sub = Submission.new
      sub.author_email.should == ''
    end
  end

  describe "#author_name=" do
    it "sets an attribute that is not written to the database" do
      sub = Factory.create :submission, author_name: 'Pablo Honey'
      sub.author_name.should == 'Pablo Honey'
      sub.should == Submission.first
      Submission.first.author_name.should_not == 'Pablo Honey'
    end
  end
  describe "#author_email=" do
    it "sets an attribute that is not written to the database" do
      sub = Factory.create :submission, author_email: 'phc@example.com'
      sub.author_email.should == 'phc@example.com'
      sub.should == Submission.first
      Submission.first.author_email.should_not == 'phc@example.com'
    end
  end
  describe "#author=" do
    it "sets the author from the given person" do
      person = Factory.create :person
      sub = Submission.new title: 'this', body: 'that'
      sub.author = person
      sub.save
      sub.author.should == person
    end
  end

  context "when not passed an author" do
    it "creates a person from a present author_name and author_email" do
      sub = Submission.create(
        title: 'this',
        body:  'that',
        author_name: 'Pablo Honey',
        author_email: 'phc@example.com'
      )
      person = sub.author
      person.name.should == 'Pablo Honey'
      person.email.should == 'phc@example.com'
    end
    context "but the given author_email already belongs to someone" do
      let(:person) { Factory.create :person }

      it "associates the submission with that someone" do
        sub = Submission.create(
          title: 'this',
          body:  'that',
          author_name: person.name,
          author_email: person.email
        )
        sub.author.should == person
      end
      it "sets the pseudonym from the author_name, if different from that someone's name" do
        sub = Submission.create(
          title: 'this',
          body:  'that',
          author_name: "Dan Deacon",
          author_email: person.email
        )
        sub.pseudonym.to_s.should == "Dan Deacon"
      end
    end
    it "emails the author_email to let them know that someone submitted for them" do
      sub = Submission.new(
        title: 'this',
        body:  'that',
        author_name: 'Pablo Honey',
        author_email: 'phc@example.com'
      )
      mock_mail = mock(:mail)
      mock_mail.stub(:deliver)
      Notifications.should_receive(:submitted_while_not_signed_in).with(sub).and_return(mock_mail)
      sub.save
    end
    it "associates the submission with the author having the given author_name" do
      person = Factory.create :person
    end
    it "gives an error if author_name isn't present" do
      sub = Submission.create(
        title: 'this',
        body:  'that',
        author_name: '',
        author_email: 'phc@example.com'
      )
      sub.should_not be_valid
    end
    it "gives an error if author_email isn't present" do
      sub = Submission.create(
        title: 'this',
        body:  'that',
        author_email: '',
        author_email: 'phc@example.com'
      )
      sub.should_not be_valid
    end
  end

  describe "#average_score" do
    before :each do
      @issue = Factory.create :issue
      @meeting = @issue.meetings.create datetime: Time.now, issue: @issue
      @submission = Factory.create :submission, issue: @issue
      @person = Factory.create :person
      @person2 = Factory.create :person

      @meeting.people = [@person, @person2]
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
      meeting.update_attributes :issue => @issue
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

  describe "#issue" do
    before { Submission.any_instance.unstub(:publication) }
    let(:publication) { Factory.create(:publication) }
    it "defaults to the current issue" do
      mg1 = Factory.build :issue, publication: publication
      mg2 = Factory.build :issue, publication: publication
      publication.stub(:current_issue!).and_return(mg1)
      sub = Submission.new publication: publication
      sub.issue.should be mg1
    end
    it "creates a new issue and is set to that if the latest issue is no longer accepting submissions" do
      issue = Issue.create(
        accepts_submissions_from:  6.months.ago,
        accepts_submissions_until: Date.yesterday,
        publication: publication
      )
      sub = Submission.create title: '<', body: '3', author: Factory.create(:person), publication: publication
      sub.issue.should_not == issue
    end
    it "does not override the issue if it's already set" do
      mg1 = Factory.create :issue, publication: publication
      mg2 = Factory.create :issue, publication: publication
      sub = Submission.create title: "margeret", body: "tatcher", author: Factory.create(:person), issue: mg1
      publication.stub(:current_issue!).and_return(mg2)
      sub.reload.issue.should == mg1
    end
  end

  describe "#average_score" do
    before :each do
      @issue = Factory.create :issue
      @meeting = @issue.meetings.create datetime: Time.now
      @submission = Factory.create :submission
      @person = Factory.create :person
      @person2 = Factory.create :person

      @meeting.people = [@person, @person2]
      @meeting.update_attributes :issue => @issue
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
      meeting.update_attributes :issue => @issue
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

  describe "self.published" do
    it "returns only published submissions" do
      s1 = Factory.create :submission, state: Submission.state(:published)
      s2 = Factory.create :submission, state: Submission.state(:rejected)
      Submission.published.should == [s1]
    end
  end

end
