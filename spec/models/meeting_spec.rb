require 'spec_helper'

describe Meeting do
  it {
    should have_many(:attendees).dependent(:destroy)
    should have_many(:people).through(:attendees)
    should have_many(:packlets).dependent(:destroy)
    should have_many(:submissions).through(:packlets)
    should belong_to(:magazine)
  }

  it "sets all of its submissions to :reviewed if it is rescheduled to the past" do
    meeting = Factory.create :meeting
    submission = Factory.create :submission
    meeting.submissions << submission
    meeting.update_attribute :datetime, 2.hours.from_now
    submission.reload.should be_reviewed
  end

  it "sets all of its submissions to :queued if it is rescheduled to the future" do
    meeting = Meeting.create :datetime => 1.week.ago, :question => "orly?"
    submission = Factory.create :submission
    meeting.submissions << submission
    submission.reload.should be_reviewed
    meeting.update_attribute :datetime, 1.week.from_now
    submission.reload.should be_queued
  end

  describe "#create" do
    it "will automatically be associated with the magazine in whose range it falls" do
      mag = Magazine.create
      meeting = Meeting.create :question => "would you believe it?", :datetime => Date.tomorrow
      meeting.magazine.should == mag
    end
  end
end
