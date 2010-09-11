require 'test_helper'

class MeetingTest < ActiveSupport::TestCase
  should "be valid" do
    assert Meeting.new.valid?
  end
end
