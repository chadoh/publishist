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
    @submission   = Factory.create :submission
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

  it "destroys the score if updated with a blank amount" do
    @s = Score.create(:amount => 1, :packlet => @packlet, :attendee => @attendee)
    @s.update_attributes('amount' => '')
    Score.all.should be_empty
  end

  it "does not destroy the score if updated with a present amount" do
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

  def an_issue_is_in_process
    @issue = Issue.create(:nickname => "Wholly Mammoth",
      accepts_submissions_from: 3.months.ago,
      accepts_submissions_until: 3.months.from_now
    )
    @meeting = Meeting.create(datetime: Date.yesterday, issue: @issue)
    @sub     = Factory.create :submission
    @sub2    = Factory.create :submission
    @p        = Factory.create :person
    @p2       = Factory.create :person
    @a        = Attendee.create :meeting => @meeting, :person => @p
    @a2       = Attendee.create :meeting => @meeting, :person => @p2
    @packlet  = Packlet.create  :meeting => @meeting, :submission => @sub
    @packlet2 = Packlet.create  :meeting => @meeting, :submission => @sub2
  end

  context "when created" do
    before do
      an_issue_is_in_process
      Score.create :packlet => @packlet, :attendee => @a, :amount => '5'
    end

    it "increments its submission's issue count_of_scores by 1" do
      @issue.reload.count_of_scores.should == 1
    end

    it "increments its submission's issue sum_of_scores by its :amount" do
      @issue.reload  .sum_of_scores.should == 5
    end
  end

  context "when updated" do
    it "changes its submission's issue sum_of_scores by its :amount delta" do
      an_issue_is_in_process
      score = Score.create :packlet => @packlet, :attendee => @a, :amount => '5'
      score.update_attributes 'amount' => 8
      @issue.reload.count_of_scores.should == 1
      @issue.reload.sum_of_scores.should == 8
    end
  end


  context "when deleted" do
    it "sets its submission to :reviewed (if last one)" do
      @s = @packlet.scores.create :amount => 6, :attendee => @attendee
      @s.destroy
      @submission.reload.should be_reviewed
    end

    it "doesn't set its submission to :reviewed (if not the last one)" do
      person = Factory.create :person
      attendee2 = Attendee.create :meeting => @meeting, :person => person
      @s = @packlet.scores.create :amount => 6, :attendee => @attendee
      @s2 = @packlet.scores.create :amount => 6, :attendee => attendee2
      @s.destroy
      @submission.reload.should be_scored
    end

    describe "self.packlet.issue" do
      before do
        an_issue_is_in_process
        score = Score.create :packlet => @packlet, :attendee => @a, :amount => '5'
        score.destroy
        @issue = score.packlet.meeting.issue
      end

      it "reduces :count_of_scores by 1" do
        @issue.count_of_scores.should == 0
      end

      it "reduces :sum_of_scores by its :amount" do
        @issue.sum_of_scores.should == 0
      end
    end
  end

end
