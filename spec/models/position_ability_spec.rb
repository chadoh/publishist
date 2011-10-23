require 'spec_helper'

describe PositionAbility do
  it {
    should belong_to(:position)
    should belong_to(:ability)
    should have_one(:magazine).through(:position)
    should validate_presence_of :position_id
    should validate_presence_of :ability_id
  }
end
