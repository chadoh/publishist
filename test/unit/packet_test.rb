require 'test_helper'

class PacketTest < ActiveSupport::TestCase
  should belong_to :meeting
  should belong_to :composition

  should validate_presence_of :meeting_id
  should validate_presence_of :composition_id
  should validate_presence_of :position
end
