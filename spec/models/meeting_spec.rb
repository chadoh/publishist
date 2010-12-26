require 'spec_helper'

describe Meeting do
  it {
    should have_many(:attendances).dependent(:destroy)
    should have_many(:people).through(:attendances)
    should have_many(:packets).dependent(:destroy)
    should have_many(:submissions).through(:packets)
  }
end
