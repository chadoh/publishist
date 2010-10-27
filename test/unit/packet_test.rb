require 'test_helper'

class PacketTest < ActiveSupport::TestCase
  should belong_to :meeting
  should belong_to :composition

  should validate_presence_of :meeting_id
  should validate_presence_of :composition_id

  should "only allow a composition to be reviewed once in a meeting" do
    @p1 = Factory.create :packet
    @p2 = Packet.new :composition => @p1.composition, :meeting => @p1.meeting
    assert !@p2.valid?
  end

  should "allow a composition to be reviewed at more than one meeting" do
    @p1 = Factory.create :packet
    @m2 = Factory.create :meeting2
    @p2 = Packet.new :composition => @p1.composition, :meeting => @m2
    assert @p2.valid?

    @p2 = Factory.create :packet2
    assert_not_equal @p2.meeting, @p1.meeting
    assert_not_equal @p2.composition, @p1.composition
    @p3 = Packet.new :composition => @p2.composition, :meeting => @p1.meeting
    assert @p3.valid?
  end

  context "a packet" do
    setup do
      @p1 = Factory.create :packet
      @meeting = @p1.meeting
      @p2 = Packet.create :meeting => @meeting,
        :composition => Factory.create(:anonymous_poetry_submission)
    end

    should "be able to be sorted up and down" do
      assert_equal @meeting.packets.last, @p2
      @meeting.packets.first.move_lower
      assert_equal @meeting.packets.last, @p1
    end
  end
end
