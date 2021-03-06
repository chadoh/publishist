require 'spec_helper'

describe Packlet do
  before do
    @meeting = Factory.create :meeting
    @submission = Factory.create :submission
    @packlet = @meeting.packlets.create :submission => @submission
  end


  it {
    should belong_to :meeting
    should belong_to :submission
    should have_many :scores

    should validate_presence_of :meeting_id
    should validate_presence_of :submission_id
  }

  it "only allows a submission to be reviewed once per meeting" do
    @p1 = Factory.create :packlet
    @p2 = Packlet.new :submission => @p1.submission, :meeting => @p1.meeting
    @p2.should_not be_valid
  end

  it "allows a submission to be reviewed at multiple meetings" do
    @p1 = Factory.create :packlet
    @m2 = Factory.create :meeting
    @p2 = Packlet.new :submission => @p1.submission, :meeting => @m2
    @p2.should be_valid

    @p2 = Factory.create :packlet
    @p2.meeting.should_not == @p1.meeting
    @p2.submission.should_not == @p1.submission

    @p3 = Packlet.new :submission => @p2.submission, :meeting => @p1.meeting
    @p3.should be_valid
  end

  it "updates a submission's :issue, if different than the meeting's" do
    issue = Factory.create :issue
    mg2 = Factory.create :issue
    sub = Factory.create :submission, issue: issue
    mtg = mg2.meetings.create datetime: Time.now
    mtg.submissions << sub
    sub.issue.should == mg2
  end

  it "does not allow a submission to be scheduled for meetings in different issues" do
    issue = Factory.create :issue
    mg2 = Factory.create :issue
    sub = Factory.create :submission, issue: issue
    mtg = issue.meetings.create datetime: Time.now
    mtg.submissions << sub
    mtg2 = mg2.meetings.create datetime: Time.now
    packlet = Packlet.new meeting: mtg2, submission: sub.reload
    packlet.should_not be_valid
  end

  it "updates a packlet's position without a problem" do
    sub2 = Factory.create :submission
    packlet2 = @meeting.packlets.create submission: sub2
    packlet2.position.should be > @packlet.reload.position
    packlet2.move_to_top
    packlet2.position.should be < @packlet.reload.position
  end

  describe "#submission#draft?" do
    it "returns false, since a submission can only be scheduled after it's submitted" do
      @packlet.submission.draft?.should be_false
    end
  end

  describe "#create" do
    it "sets the packlet's submission to :queued if the meeting is in the future" do
      @packlet.submission.should be_queued
    end

    it "sets the packlet's submission to :reviewed if the meeting is in the past" do
      meeting = Meeting.create :datetime => 2.hours.from_now,
                               :question => "Jim?"
      packlet = meeting.packlets.create :submission => @submission
      packlet.submission.should be_reviewed
    end
  end

  describe "#destroy" do
    it "sets the packlet's submission to :submitted if this was its last packlet" do
      sub = @packlet.submission
      @packlet.destroy
      sub.reload.state.should == :submitted
      sub.should be_submitted
    end

    it "doesn't set the packlet's submission to :submitted if it _wasn't_ its last packlet" do
      sub = @packlet.submission
      meeting2 = Factory.create :meeting
      packlet2 = Packlet.create :meeting => meeting2, :submission => sub
      packlet2.destroy
      sub.should be_queued
    end

    it "accepts a {:current_person => blah} parameter without complaining" do
      person = Factory.build :person
      @packlet.destroy :current_person => person
    end
  end
end
