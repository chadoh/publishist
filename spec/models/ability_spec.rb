require 'spec_helper'

describe Ability do
  it {
    should have_many(:position_abilities)
    should have_many(:positions).through(:position_abilities)
    should have_many(:roles).through(:positions)
    should have_many(:people).through(:roles)
    should validate_presence_of :key
    should validate_presence_of :description
  }
end
