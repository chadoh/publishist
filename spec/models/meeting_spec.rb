require 'spec_helper'

describe Meeting do
  it {
    should have_many(:attendees).dependent(:destroy)
    should have_many(:people).through(:attendees)
    should have_many(:packlets).dependent(:destroy)
    should have_many(:submissions).through(:packlets)
    should belong_to(:magazine)
    should validate_presence_of(:datetime)
  }

  context "when saving" do
    before do
      @meeting = Factory.create :meeting
      @submission = Factory.create :submission
      @meeting.submissions << @submission
    end

    it "sets all of its submissions to :reviewed if it is rescheduled to the past" do
      @meeting.update_attribute :datetime, 2.hours.from_now
      @submission.reload.should be_reviewed
    end

    it "sets all of its submissions to :queued if it is rescheduled to the future" do
      @meeting.update_attribute :datetime, 1.week.from_now
      @submission.reload.should be_queued
    end

    it "doesn't touch the state of submissions if they are :scored" do
      @submission.has_been :scored
      @meeting.update_attributes :question => "orly?"
      @submission.reload.should be_scored
    end

    it "doesn't touch the state of submissions if they are :published" do
      @submission.has_been :published
      @meeting.update_attributes :question => "orly?"
      @submission.reload.should be_published
    end

    it "doesn't touch the state of submissions if they are :rejected" do
      @submission.has_been :rejected
      @meeting.update_attributes :question => "orly?"
      @submission.reload.should be_rejected
    end
  end

  describe "#magazine" do
    it "initializes to the current magazine" do
      mag = Magazine.create
      meeting = Meeting.new datetime: Time.zone.now - 1.year
      meeting.magazine.should == mag
    end

    it "can be changed" do
      mag = Magazine.create accepts_submissions_from: 2.months.ago, accepts_submissions_until: 2.months.from_now
      mag2 = Magazine.create
      meeting = Meeting.create :question => "would you believe it?", :datetime => Date.tomorrow
      meeting.magazine.should == mag
      meeting.update_attributes :magazine => mag2
      meeting.magazine.should == mag2
    end
  end
end
