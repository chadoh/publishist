require 'spec_helper'

describe ConfirmationsController do
  describe "routing" do
    context "when on a subdomain" do
      let(:domain) { "http://pc.publishist.test" }

      it "routes to #update" do
        expect(put "#{domain}/person/confirmation").to route_to("confirmations#update")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(put "#{domain}/person/confirmation").not_to route_to("confirmations#update")
      end
    end
  end
end
