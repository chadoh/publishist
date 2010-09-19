require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  should belong_to :meeting
  should belong_to :person
  should validate_presence_of :meeting_id
  should validate_presence_of :person_id
end
