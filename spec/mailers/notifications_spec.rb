require 'spec_helper'

describe "Notifications mailer" do
  let(:editor) { double("editor", name: "Spec Helper Editor", email: "woo@woo.woo").as_null_object }
  let(:publication) { Factory.create(:publication) }
  before do
    Submission.any_instance.unstub(:publication)
    Magazine.any_instance.unstub(:publication)
    Person.any_instance.unstub(:primary_publication)
    publication.stub(:editor).and_return(editor)
  end

  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  describe "#submitted_while_not_signed_in" do
    let(:submission) { Submission.new(title: 'woo', body: 'tang', publication: publication, author: Factory.create(:person)) }
    let(:email)      { Notifications.submitted_while_not_signed_in(submission) }

    subject { email }

    it { should be_multipart }
    it { should have_subject /Someone \(hopefully you!\) submitted to .+ for you!/ }
    it { should deliver_from "#{editor.name} <support@publishist.com>" }
    it { should have_reply_to editor.email }
    it { should deliver_to submission.author_email }
    it { should have_body_text "publishist.dev#{person_path(submission.author)}" }
    it { should_not have_body_text "//publishist" }
    it { should have_body_text "//#{publication.subdomain}.publishist" }
  end

  describe "#new_submission" do
    let(:submission) { Submission.create(title: 'woo', body: 'tang', publication: publication, author: Factory.create(:person)) }
    let(:email)      { Notifications.new_submission(submission) }

    subject { email }

    it { should have_body_text(submission.title) }
    it { should have_subject /#{submission.title}/ }
    it { should be_multipart }
    it { should_not have_body_text "//publishist" }
    it { should have_body_text "//#{publication.subdomain}.publishist" }
  end

  describe "#we_published_a_magazine" do
    let(:published) { Submission.create state: :published, publication: publication, title: 'woo', body: 'tang', author: Factory.create(:person) }
    let(:rejected) { Submission.create state: :rejected, publication: publication, title: 'woo', body: 'tang', author: published.author }
    let(:magazine) { Magazine.create publication: publication }
    let(:email) { Notifications.we_published_a_magazine(published.email, magazine, [published, rejected]) }

    subject { email }

    it { should be_multipart }
    it { should have_body_text published.title }
    it { should have_body_text rejected.title }
    it { should have_body_text submission_path(published) }
    it { should have_body_text submission_path(rejected) }
    it { should_not have_body_text "//publishist" }
    it { should have_body_text "//#{publication.subdomain}.publishist" }
  end

  describe "#we_published_a_magazine_a_while_ago" do
    let(:published) { Submission.create state: :published, publication: publication, title: 'woo', body: 'tang', author: Factory.create(:person) }
    let(:rejected) { Submission.create state: :rejected, publication: publication, title: 'woo', body: 'tang', author: published.author }
    let(:magazine) { Magazine.create publication: publication }
    let(:email) { Notifications.we_published_a_magazine_a_while_ago(published.email, magazine, [published, rejected]) }

    subject { email }

    it { should be_multipart }
    it { should have_body_text published.title }
    it { should have_body_text rejected.title }
    it { should have_body_text submission_path(published) }
    it { should have_body_text submission_path(rejected) }
    it { should_not have_body_text "//publishist" }
    it { should have_body_text "//#{publication.subdomain}.publishist" }
  end
end
