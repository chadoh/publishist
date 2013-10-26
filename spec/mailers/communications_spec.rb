require 'spec_helper'

describe "Communications mailer" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  describe "#contact_person" do
    let(:publication) { Factory.build :publication }
    let(:contacter) { Factory.build :person, slug: "contacter", primary_publication: publication }
    let(:contactee) { Factory.build :person, slug: "contactee", primary_publication: publication }
    let(:email) { Communications.contact_person contactee, contacter, "We have similar names!", "Nifty." }
    before do
      Person.any_instance.unstub(:primary_publication)
    end

    subject { email }

    it { should have_body_text("We have similar names!") }
    it { should have_body_text("Nifty") }
    it { should have_subject(/#{contacter.name}/) }
    it { should be_multipart }
    it { should deliver_from "#{contacter.name} <support@publishist.com>" }
    it { should deliver_to contactee.email }
    it { should have_reply_to contacter.email }
    it { should_not have_body_text "//publishist" }
    it { should have_body_text "//#{publication.subdomain}.publishist" }
  end
end
