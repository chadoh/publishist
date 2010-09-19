require 'test_helper'

class MeetingTest < ActiveSupport::TestCase
  should_have_many :attendances, :dependent => :destroy
  should_have_many :people, :through => :attendances
  should "be valid" do
    assert Meeting.new.valid?
  end
end
