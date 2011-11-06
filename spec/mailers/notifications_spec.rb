require 'spec_helper'

describe "Notifications mailer" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  describe "#new_submission" do
    before :all do
      @submission = Submission.create(
        :title => 'mehrrrow <strong>ROAR!</strong>',
        :body => "He's the fairest of 10,000 to my <sup>soul</sup>",
        :author_email => 'froyo@doyo.net'
      )
      @email = Notifications.new_submission(@submission)
    end

    subject { @email }
    it {
      should have_body_text(@submission.title)
      should have_subject(/mehrrrow ROAR!/)
      should be_multipart
    }
  end

  describe "#we_published_a_magazine" do
    before :all do
      @submission = Submission.create(
        :title => 'mehrrrow <strong>ROAR!</strong>',
        :body => "He's the fairest of 10,000 to my <sup>soul</sup>",
        :author_email => 'froyo@doyo.net',
        :state => Submission.state(:published)
      )
      @magazine = Magazine.create
      @meeting = Meeting.create(:question => "orly?", :datetime => 1.week.from_now)
      @email = Notifications.we_published_a_magazine(@submission.email, @magazine, [@submission])
    end

    subject { @email }
    it {
      should be_multipart
      should have_body_text "mehrrrow ROAR!"
      should have_body_text "problemchildmag.com#{submission_path(@submission)}"
    }
  end

  describe "#we_published_a_magazine_a_while_ago" do
    before :all do
      @submission = Submission.create(
        :title => 'mehrrrow <strong>ROAR!</strong>',
        :body => "He's the fairest of 10,000 to my <sup>soul</sup>",
        :author_email => 'froyo@doyo.net',
        :state => Submission.state(:published)
      )
      @magazine = Magazine.create
      @meeting = Meeting.create(:question => "orly?", :datetime => 1.week.from_now)
      @email = Notifications.we_published_a_magazine_a_while_ago(@submission.email, @magazine, [@submission])
    end

    subject { @email }
    it {
      should be_multipart
      should have_body_text "mehrrrow ROAR!"
      should have_body_text "problemchildmag.com#{submission_path(@submission)}"
    }
  end
end
