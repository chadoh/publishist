require 'spec_helper'

describe StaffList do
  before :each do
    @staff_list = StaffList.new
  end

  it {
    should belong_to :page
    should have_one(:magazine).through(:page)
  }

end
