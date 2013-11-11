require 'spec_helper'

describe Position do
  it {
    should belong_to(:issue)
    should have_many(:roles).dependent(:destroy)
    should have_many(:people).through(:roles)
    should have_many(:position_abilities).dependent(:destroy)
    should have_many(:abilities).through(:position_abilities)
    should validate_presence_of :name
    should validate_presence_of :issue_id
  }
end
