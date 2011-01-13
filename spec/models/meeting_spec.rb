require 'spec_helper'

describe Meeting do
  it {
    should have_many(:attendances).dependent(:destroy)
    should have_many(:people).through(:attendances)
    should have_many(:packets).dependent(:destroy)
    should have_many(:submissions).through(:packets)
  }

  describe "#attendees_who_have_not_entered_scores_themselves," do
    let(:meeting)    { Factory.create :meeting }
    let(:person)     { Factory.create :person }
    let(:submission) { Factory.create :submission }

    let(:packet) { Packet.create(:submission => submission, :meeting => meeting) }

    context "when 3 people attend the meeting" do
      before do
        @attendance = Attendance.create(:person => person, :meeting => meeting)
        2.times do
          p = Factory.create :person
          Attendance.create(:person => p, :meeting => meeting)
        end
      end

      describe "and none enter scores themselves," do
        it "returns 3 attendees" do
          meeting.attendees_who_have_not_entered_scores_themselves.length.should == 3
        end
      end

      describe "and one enters scores on the website," do
        it "returns 2 attendees" do
          Score.create(:amount => 5, :packet => packet, :attendance => @attendance)
          meeting.attendees_who_have_not_entered_scores_themselves.length.should == 2
        end
      end

      describe "and one has scores entered by the coeditor already," do
        it "returns 3 attendees" do
          Score.create(:amount => 5, :packet => packet, :attendance => @attendance, :entered_by_coeditor => true)
          meeting.attendees_who_have_not_entered_scores_themselves.length.should == 3
        end
      end
    end
  end
end
