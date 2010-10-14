require 'test_helper'

class PacketTest < ActiveSupport::TestCase
  should belong_to :meeting
  should belong_to :composition

  should validate_presence_of :meeting_id
  should validate_presence_of :composition_id

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
