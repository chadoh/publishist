require 'test_helper'

class PacketTest < ActiveSupport::TestCase
  should belong_to :meeting
  should belong_to :composition

  should validate_presence_of :meeting_id
  should validate_presence_of :composition_id
  should validate_presence_of :position

  context "a packet" do
    setup do
      @p1 = Factory.create :packet
      @p2 = Factory.create :packet2
      @meeting = @p1.meeting
    end

    should "be able to be sorted up and down" do
      assert_equal @meeting.last, @p2
      @meeting.first.move_lower
      assert_equal @meeting.last, @p1
    end
  end
end
