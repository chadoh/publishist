require 'spec_helper'

describe Publication do
  it {
    should have_many(:magazines)
    should have_many(:submissions)
  }
end
