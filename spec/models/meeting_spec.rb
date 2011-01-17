require 'spec_helper'

describe Meeting do
  it {
    should have_many(:attendees).dependent(:destroy)
    should have_many(:people).through(:attendees)
    should have_many(:packlets).dependent(:destroy)
    should have_many(:submissions).through(:packlets)
  }

  describe "#attendees_who_have_not_entered_scores_themselves," do
    let(:meeting)    { Factory.create :meeting }
    let(:person)     { Factory.create :person }
    let(:submission) { Factory.create :submission }

    let(:packlet) { Packlet.create(:submission => submission, :meeting => meeting) }

    context "when 3 people attend the meeting" do
      before do
        @attendee = Attendee.create(:person => person, :meeting => meeting)
        2.times do
          p = Factory.create :person
          Attendee.create(:person => p, :meeting => meeting)
        end
      end

      describe "and none enter scores themselves," do
        it "returns 3 attendees" do
          meeting.attendees_who_have_not_entered_scores_themselves.length.should == 3
        end
      end

      describe "and one enters scores on the website," do
        it "returns 2 attendees" do
          Score.create(:amount => 5, :packlet => packlet, :attendee => @attendee)
          meeting.attendees_who_have_not_entered_scores_themselves.length.should == 2
        end
      end

      describe "and one has scores entered by the coeditor already," do
        it "returns 3 attendees" do
          Score.create(:amount => 5, :packlet => packlet, :attendee => @attendee, :entered_by_coeditor => true)
          meeting.attendees_who_have_not_entered_scores_themselves.length.should == 3
        end
      end
    end
  end
end
