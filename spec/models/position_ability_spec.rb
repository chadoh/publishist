require 'spec_helper'

describe PositionAbility do
  it {
    should belong_to(:position)
    should belong_to(:ability)
    should validate_presence_of :position_id
    should validate_presence_of :ability_id
  }
end
