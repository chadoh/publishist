require 'spec_helper'

describe "Notifications mailer" do
  let(:editor) { double("editor", name: "Spec Helper Editor", email: "woo@woo.woo").as_null_object }
  let(:publication) { double("publication", editor: editor).as_null_object }
  before do
    Magazine.any_instance.stub(:publication).and_return(publication)
  end

  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  describe "#submitted_while_not_signed_in" do
    let(:submission) { Factory.build(:submission) }
    let(:email)      { Notifications.submitted_while_not_signed_in(submission) }

    subject { email }

    it { should be_multipart }
    it { should have_subject /Someone \(hopefully you!\) submitted to .+ for you!/ }
    it { should deliver_from "#{editor.name} <donotreply@publishist.com>" }
    it { should have_reply_to editor.email }
    it { should deliver_to submission.author_email }
    it { should have_body_text "publishist.dev#{person_path(submission.author)}" }
  end

  describe "#new_submission" do
    let(:submission) { Factory.create :submission }
    let(:email)      { Notifications.new_submission(submission) }

    subject { email }

    it { should have_body_text(submission.title) }
    it { should have_subject /#{submission.title}/ }
    it { should be_multipart }
  end

  describe "#we_published_a_magazine" do
    let(:submission) { Factory.create :submission, state: :published }
    let(:magazine)   { Magazine.create }
    let(:email)      { Notifications.we_published_a_magazine(submission.email, magazine, [submission]) }

    subject { email }

    it { should be_multipart }
    it { should have_body_text submission.title }
    it { should have_body_text "publishist.dev#{submission_path(submission)}" }
  end

  describe "#we_published_a_magazine_a_while_ago" do
    let(:submission) { Factory.create :submission, state: :published }
    let(:magazine)   { Magazine.create }
    let(:email)      { Notifications.we_published_a_magazine_a_while_ago(submission.email, magazine, [submission]) }

    subject { email }

    it { should be_multipart }
    it { should have_body_text submission.title }
    it { should have_body_text "publishist.dev#{submission_path(submission)}" }
  end
end
