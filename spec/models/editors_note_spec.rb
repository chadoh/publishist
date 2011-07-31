require 'spec_helper'

describe EditorsNote do
  before :each do
    @editors_notes = EditorsNote.new
  end

  it {
    should belong_to :page
  }

end
