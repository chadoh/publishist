require 'spec_helper'

describe Packet do
  it {
    should belong_to :meeting
    should belong_to :composition

    should validate_presence_of :meeting_id
    should validate_presence_of :composition_id
  }

  it "only allows a composition to be reviewed once per meeting" do
    @p1 = Factory.create :packet
    @p2 = Packet.new :composition => @p1.composition, :meeting => @p1.meeting
    @p2.should_not be_valid
  end

  it "allows a composition to be reviewed at multiple meetings" do
    @p1 = Factory.create :packet
    @m2 = Factory.create :meeting
    @p2 = Packet.new :composition => @p1.composition, :meeting => @m2
    @p2.should be_valid

    @p2 = Factory.create :packet
    @p2.meeting.should_not == @p1.meeting
    @p2.composition.should_not == @p1.composition

    @p3 = Packet.new :composition => @p2.composition, :meeting => @p1.meeting
    @p3.should be_valid
  end
end
