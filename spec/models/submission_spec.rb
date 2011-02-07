require 'spec_helper'

describe Submission do
  before(:each) do
    @person = Factory.create :person
  end

  it {
    should have_many(:packlets).dependent(:destroy)
    should have_many(:meetings).through(:packlets)
    should belong_to(:author)
  }

  it "sets queued submissions to reviewed if their meeting is less than three hours in the future" do
    meeting = Factory.create :meeting
    submission = Factory.create :submission
    meeting.submissions << submission
    meeting.update_attribute :datetime, 2.hours.from_now
    submission.reload.should be_reviewed
    submission.update_attribute :state, Submission.state(:queued)
    submission.should be_queued
    submission.reload.should be_reviewed
  end

  describe "#has_been" do
    it "moves the sumbission into the specified state" do
      sub = Factory.build :submission
      sub.has_been :submitted
      sub.state.should == :submitted
    end
  end

  context "has methods to check if in a certain state:" do
    before :each do
      @sub = Submission.create :title => "Cheese",
                               :body => "Whiz",
                               :author => Factory.create(:person)
    end

    it "has a #draft? method" do
      (@sub.draft?).should be_true
    end

    it "has a #submitted? method" do
      (@sub.submitted?).should be_false
    end
  end

  describe "#author" do
    context "when there is an associated author" do
      before(:each) do
        @sub = Submission.create(
          :title  => ';-)',
          :body   => 'he winks and smiles <br><br> both',
          :author => @person)
      end

      it "returns the associated author's name" do
        @sub.author.should == @person.name
      end

      it "returns a person object if passed 'true'" do
        @sub.author(true).should == @person
      end
    end

    context "when there is no associated author" do
      before(:each) do
        @sub = Submission.create :title => ';-)',
          :body => 'he winks and smiles <br><br> both',
          :author_email => 'me@you.com',
          :author_name => @person
      end

      it "returns the author_name field" do
        @sub.author.should == @person
      end

      it "returns nil if passed 'true'" do
        @sub.author(true).should == nil
      end
    end
  end
end
