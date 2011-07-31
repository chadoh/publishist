require 'spec_helper'

describe CoverArt do
  before :each do
    @cover_art = CoverArt.new
  end

  it {
    should belong_to :page
  }

end
