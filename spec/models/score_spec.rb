require 'spec_helper'

describe Score do
  it {
    should belong_to :packlet
    should belong_to :attendee
    should have_one(:meeting).through(:packlet)

    should validate_presence_of :packlet
    should validate_presence_of :attendee
    should validate_presence_of :amount
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

  it "validates that only one score is created for a particular attendee and packlet" do
    @s = Score.create(:amount => 1, :packlet => @packlet, :attendee => @attendee)
    @s2 = Score.new(:amount => 1, :packlet => @packlet, :attendee => @attendee)
    @s2.should_not be_valid
  end

  it "sets amount to 1 if submitted as less than 1" do
    @s = @packlet.scores.create :attendee => @attendee, :amount => 0
    @s.should be_valid
    @s.amount.should == 1
  end

  it "sets amount to 10 if submitted as more than 10" do
    @s = @packlet.scores.create :attendee => @attendee, :amount => 11
    @s.should be_valid
    @s.amount.should == 10
  end

  it "sets amount to 1 if non-numeric characters are submitted" do
    @s = @packlet.scores.create :attendee => @attendee, :amount => "a"
    @s.should be_valid
    @s.amount.should == 1
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
    it "returns the score with a given attendee and packlet" do
      @s = Score.create(:amount => 1, :attendee => @attendee, :packlet => @packlet)
      Score.with(@attendee, @packlet).should == @s
    end

    it "returns a new score with the given attendee and packlet if none exists yet" do
      @s = Score.with(@attendee, @packlet)
      @s.id.should be_nil
      @s.amount.should be_nil
      @s.attendee.should == @attendee
      @s.packlet.should == @packlet
    end

    it "returns a *new* score even if a similar one was just deleted" do
      @s = Score.create(:amount => 1, :attendee => @attendee, :packlet => @packlet)
      @s.destroy
      @s2 = Score.with(@attendee, @packlet)
      @s2.id.should be_nil
      @s2.amount.should be_nil
    end

    it "sets 'entered_by_coeditor' to true told to do so" do
      @s = Score.with @attendee, @packlet, :entered_by_coeditor => true
      @s.should be_entered_by_coeditor
    end
  end

  it "sets its submission to scored" do
    @s = @packlet.scores.create :amount => 6, :attendee => @attendee
    @submission.reload.should be_scored
  end

  it "sets its submission to :reviewed when deleted (if last one)" do
    @s = @packlet.scores.create :amount => 6, :attendee => @attendee
    @s.destroy
    @submission.reload.should be_reviewed
  end

  it "doesn't set its submission to :reviewed when deleted if not the last one" do
    person = Factory.create :person
    attendee2 = Attendee.create :meeting => @meeting, :person => person
    @s = @packlet.scores.create :amount => 6, :attendee => @attendee
    @s2 = @packlet.scores.create :amount => 6, :attendee => attendee2
    @s.destroy
    @submission.reload.should be_scored
  end

end
