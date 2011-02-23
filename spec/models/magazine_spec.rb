require 'spec_helper'

describe Magazine do
  it {
    should validate_presence_of :nickname
    should validate_presence_of :accepts_submissions_from
    should validate_presence_of :accepts_submissions_until
  }

  describe "#nickname" do
    it "defaults to 'next'" do
      mag = Magazine.new
      mag.nickname.should == "next"
    end
  end

  describe "#accepts_submissions_from" do
    it "defaults to today" do
      mag = Magazine.new
      mag2 = Magazine.new :accepts_submissions_from => Date.today
      mag.accepts_submissions_from.should == mag2.accepts_submissions_from
    end
  end

  describe "#accepts_submissions_until" do
    it "defaults to today" do
      mag = Magazine.new
      mag2 = Magazine.new :accepts_submissions_until => Date.today + 6.months
      mag.accepts_submissions_until.should == mag2.accepts_submissions_until
    end

    it "must be > self.accepts_submissions_from" do
      mag = Magazine.new(
        :accepts_submissions_from  => Date.today,
        :accepts_submissions_until => Date.yesterday
      )
      mag.should_not be_valid
    end
  end

  describe "with the default settings" do
    it "should be valid" do
      Magazine.new.should be_valid
    end
  end

end
