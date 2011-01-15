require 'spec_helper'

describe Score do
  it {
    should belong_to :packet
    should belong_to :attendance

    should validate_presence_of :packet
    should validate_presence_of :attendance
    should validate_presence_of :amount
    should validate_numericality_of :amount
    should ensure_inclusion_of(:amount).in_range(1..10)
  }

  before(:each) do
    @meeting      = Factory.create :meeting
    @person       = Factory.create :person
    @submission   = Factory.create :anonymous_submission
    @packet       = Packet.create(
      :meeting    => @meeting,
      :submission => @submission)
    @attendance   = Attendance.create(
      :meeting    => @meeting,
      :person     => @person)
  end

  pending "validates that only one score is created for a particular attendance and packet" do
    @s = Score.create(:amount => 1, :packet => @packet, :attendance => @attendance)
    @s2 = Score.new(:amount => 1, :packet => @packet, :attendance => @attendance)
    @s2.should_not be_valid
  end

  it "should destroy the score if updated with a blank amount" do
    @s = Score.create(:amount => 1, :packet => @packet, :attendance => @attendance)
    @s.update_attributes('amount' => '')
    Score.all.should be_empty
  end

  it "should not destroy the score if updated with a present amount" do
    @s = Score.create(:amount => 1, :packet => @packet, :attendance => @attendance)
    @s.update_attributes('amount' => '6')
    Score.all.length.should == 1
  end

  describe "#with" do
    it "should return the score with a given attendance and packet" do
      @s = Score.create(:amount => 1, :attendance => @attendance, :packet => @packet)
      Score.with(@attendance, @packet).should == @s
    end

    it "should return a new score with the given attendance and packet if none exists yet" do
      @s = Score.with(@attendance, @packet)
      @s.id.should be_nil
      @s.amount.should be_nil
      @s.attendance.should == @attendance
      @s.packet.should == @packet
    end

    it "should set 'entered_by_coeditor' to true told to do so" do
      @s = Score.with @attendance, @packet, :entered_by_coeditor => true
      @s.should be_entered_by_coeditor
    end
  end

end
