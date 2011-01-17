require 'spec_helper'

describe Score do
  it {
    should belong_to :packlet
    should belong_to :attendee

    should validate_presence_of :packlet
    should validate_presence_of :attendee
    should validate_presence_of :amount
    should validate_numericality_of :amount
    should ensure_inclusion_of(:amount).in_range(1..10)
  }

  before(:each) do
    @meeting      = Factory.create :meeting
    @person       = Factory.create :person
    @submission   = Factory.create :anonymous_submission
    @packlet       = Packlet.create(
      :meeting    => @meeting,
      :submission => @submission)
    @attendee   = Attendee.create(
      :meeting    => @meeting,
      :person     => @person)
  end

  pending "validates that only one score is created for a particular attendee and packlet" do
    @s = Score.create(:amount => 1, :packlet => @packlet, :attendee => @attendee)
    @s2 = Score.new(:amount => 1, :packlet => @packlet, :attendee => @attendee)
    @s2.should_not be_valid
  end

  it "should destroy the score if updated with a blank amount" do
    @s = Score.create(:amount => 1, :packlet => @packlet, :attendee => @attendee)
    @s.update_attributes('amount' => '')
    Score.all.should be_empty
  end

  it "should not destroy the score if updated with a present amount" do
    @s = Score.create(:amount => 1, :packlet => @packlet, :attendee => @attendee)
    @s.update_attributes('amount' => '6')
    Score.all.length.should == 1
  end

  describe "#with" do
    it "should return the score with a given attendee and packlet" do
      @s = Score.create(:amount => 1, :attendee => @attendee, :packlet => @packlet)
      Score.with(@attendee, @packlet).should == @s
    end

    it "should return a new score with the given attendee and packlet if none exists yet" do
      @s = Score.with(@attendee, @packlet)
      @s.id.should be_nil
      @s.amount.should be_nil
      @s.attendee.should == @attendee
      @s.packlet.should == @packlet
    end

    it "should set 'entered_by_coeditor' to true told to do so" do
      @s = Score.with @attendee, @packlet, :entered_by_coeditor => true
      @s.should be_entered_by_coeditor
    end
  end

end
