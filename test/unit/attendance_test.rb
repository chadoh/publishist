require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  should belong_to :meeting
  should belong_to :person
  should validate_presence_of :meeting_id
  
  def setup
    @m = Factory.create :meeting
    @p = Factory.create :person
    @a = @m.attendances.new
  end

  should "validate presence of either person_id or person_name" do
    assert !@a.valid?

    @a.person_name = "Scourges Truffle"
    assert @a.valid?

    @a.person_name = nil
    @a.person = @p
    assert @a.valid?
  end

  should "give errors if both person_id and person_name are set" do
    @a.person = @p
    @a.person_name = "Krisped Rice"
    assert !@a.valid?
  end

  should "have a method 'first_name' that returns the person's first name" do
    @a.person_name = "Macy Tiders"
    assert_equal @a.first_name, "Macy"
  end
end
