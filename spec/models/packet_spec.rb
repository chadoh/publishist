require 'spec_helper'

describe Packet do
  it {
    should belong_to :meeting
    should belong_to :submission

    should validate_presence_of :meeting_id
    should validate_presence_of :submission_id
  }

  it "only allows a submission to be reviewed once per meeting" do
    @p1 = Factory.create :packet
    @p2 = Packet.new :submission => @p1.submission, :meeting => @p1.meeting
    @p2.should_not be_valid
  end

  it "allows a submission to be reviewed at multiple meetings" do
    @p1 = Factory.create :packet
    @m2 = Factory.create :meeting
    @p2 = Packet.new :submission => @p1.submission, :meeting => @m2
    @p2.should be_valid

    @p2 = Factory.create :packet
    @p2.meeting.should_not == @p1.meeting
    @p2.submission.should_not == @p1.submission

    @p3 = Packet.new :submission => @p2.submission, :meeting => @p1.meeting
    @p3.should be_valid
  end
end
