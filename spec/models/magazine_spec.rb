require 'spec_helper'

describe Magazine do
  it {
    should validate_presence_of :nickname
    should validate_presence_of :accepts_submissions_from
    should validate_presence_of :accepts_submissions_until
    should have_many(:meetings).dependent(:nullify)
    should have_many(:submissions).through(:meetings)
  }

  describe "#nickname" do
    it "defaults to 'next'" do
      mag = Magazine.new
      mag.nickname.should == "next"
    end
  end

  describe "#accepts_submissions_from" do
    context "when this is the first magazine" do
      it "defaults to today" do
        mag = Magazine.new
        mag2 = Magazine.new :accepts_submissions_from => Date.today
        mag.accepts_submissions_from.should == mag2.accepts_submissions_from
      end
    end

    context "when there are other magazines" do
      it "defaults to the accepts_submissions_until date of the latest magazine" do
        mag = Magazine.create
        mag2 = Magazine.new
        mag2.accepts_submissions_from.should == mag.accepts_submissions_until
      end
    end

    it "cannot fall within another magazine's range" do
      orig = Magazine.create
      mag = Magazine.new :accepts_submissions_from => orig.accepts_submissions_from + 1.day
      mag.should_not be_valid
    end
  end

  describe "#accepts_submissions_until" do
    it "defaults to six months after accepts_submissions_from" do
      mag = Magazine.create
      mag.accepts_submissions_until.should == mag.accepts_submissions_from + 6.months
      # need to test another one, since the way `from` initializes changes with subsequent mags
      mag2 = Magazine.new
      mag2.accepts_submissions_until.should == mag2.accepts_submissions_from + 6.months
    end

    it "must be > self.accepts_submissions_from" do
      mag = Magazine.new(
        :accepts_submissions_from  => Date.today,
        :accepts_submissions_until => Date.yesterday
      )
      mag.should_not be_valid
    end

    it "cannot fall within another magazine's range" do
      orig = Magazine.create
      mag = Magazine.new(
        :accepts_submissions_until => orig.accepts_submissions_until - 1.day,
        :accepts_submissions_from => Date.yesterday
      )
      mag.should_not be_valid

      orig.accepts_submissions_until = orig.accepts_submissions_until - 1.day
      orig.should be_valid
    end
  end

  describe "with the default settings" do
    it "should be valid" do
      Magazine.new.should be_valid
    end
  end

  describe "#average_score" do
    it "returns the average score for the submissions in this magazine" do
      mag      = Factory.create :magazine
      mag2     = Factory.create :magazine
      meeting  = Meeting.create(:datetime => Date.tomorrow) # in mag
      meeting2 = Meeting.create(:datetime => Date.tomorrow + 6.months) # in mag2
      sub      = Factory.create :submission
      sub2     = Factory.create :submission
      p        = Factory.create :person
      p2       = Factory.create :person
      a        = Attendee.create :meeting => meeting, :person => p
      a2       = Attendee.create :meeting => meeting, :person => p2
      a3       = Attendee.create :meeting => meeting2, :person => p
      a4       = Attendee.create :meeting => meeting2, :person => p2
      packlet  = Packlet.create  :meeting => meeting, :submission => sub
      packlet2 = Packlet.create  :meeting => meeting2, :submission => sub2
      packlet.scores << [Score.create(:amount => 6, :attendee => a), Score.create(:amount => 4, :attendee => a2)]
      packlet2.scores << [Score.create(:amount => 10, :attendee => a3), Score.create(:amount => 10, :attendee => a4)]
      mag.average_score.should == 5
    end
  end

end
