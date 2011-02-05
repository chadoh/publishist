require 'spec_helper'

describe Packlet do
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

  describe "#scores_not_entered_by_coeditor" do
    before do
      @p1 = Factory.create :packlet
      3.times do
        p = Factory.create :person
        a = Attendee.create :person => p, :meeting => @p1.meeting
        Score.create :attendee => a, :packlet => @p1, :amount => 5
      end
    end

    it "returns 3 scores when none of them were entered by coeditor" do
      @p1.scores_not_entered_by_coeditor.length.should == 3
    end

    it "returns 2 scores when one of them was entered by the coeditor" do
      s = Score.first; s.entered_by_coeditor = true; s.save
      @p1.scores_not_entered_by_coeditor.length.should == 2
    end

    it "returns 1 scores when one of them was entered by the coeditor" do
      s = Score.first; s.entered_by_coeditor = true; s.save
      s = Score.last; s.entered_by_coeditor = true; s.save
      @p1.scores_not_entered_by_coeditor.length.should == 1
    end
  end

  describe "#submission#draft?" do
    it "returns false, since a submission can only be scheduled after it's submitted" do
      s = Factory.create :submission
      m = Factory.create :meeting
      p = m.packlets.create :submission => s
      p.submission.draft?.should be_false
    end
  end
end
