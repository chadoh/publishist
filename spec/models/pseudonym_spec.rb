require 'spec_helper'

describe Pseudonym do
  describe "#submission" do
    it "returns the submission that the pseudonym belongs to" do
      sub = Factory.create :submission
      pseud = Pseudonym.create name: "Pablo Honey", submission_id: sub.id
      pseud.submission.should == sub
    end
  end

  describe "#link_to_profile" do
    it "defaults to true" do
      sub = Factory.create :submission, pseudonym_name: "Pablo Honey"
      sub.pseudonym.link_to_profile.should be_true
    end
  end

  describe "#name" do
    it "cannot be blank" do
      sub = Factory.create :submission, pseudonym_name: ""
      Pseudonym.count.should == 0
      Submission.all.should == [sub]
    end
  end
end
