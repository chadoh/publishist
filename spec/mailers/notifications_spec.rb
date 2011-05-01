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
    }

    it "should be a multipart email" do
      @email.parts.length.should == 2
    end
  end
end
