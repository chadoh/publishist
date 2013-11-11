require 'spec_helper'

describe Role do
  it {
    should belong_to :person
    should belong_to :position
    should have_one(:issue).through(:position)
    should validate_presence_of :person_id
    should validate_presence_of :position_id
  }
end
