require 'spec_helper'

describe "Communications mailer" do
  include EmailSpec::Helpers
  include EmailSpec::Matchers
  include Rails.application.routes.url_helpers

  describe "#contact_person" do
    before :all do
      @person = Person.create(
        :first_name            => "Pablo",
        :last_name             => "Honey",
        :email                 => "pablo.honey@example.com",
        :password              => "password",
        :password_confirmation => "password"
      )
      @person2 = Person.create(
        :first_name            => "Paul",
        :last_name             => "Miel",
        :email                 => "paul.miel@example.com",
        :password              => "password",
        :password_confirmation => "password"
      )
      @email = Communications.contact_person(@person, @person2, "We have similar names!", "Nifty.")
    end

    subject { @email }
    it {
      should have_body_text("Nifty")
      should have_body_text("We have similar names!")
      should have_subject(/Paul Miel/)
      should be_multipart
      should deliver_from "Paul Miel <donotreply@publishist.com>"
      should deliver_to "pablo.honey@example.com"
      should have_reply_to "paul.miel@example.com"
    }
  end
end
