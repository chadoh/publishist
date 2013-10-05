require 'spec_helper'

describe PublicationDetail do
  it {
    should belong_to(:publication)
  }
end
