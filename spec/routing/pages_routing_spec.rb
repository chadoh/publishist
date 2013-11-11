require 'spec_helper'

describe PagesController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.publishist.test" }
      it "routes to #show" do
        expect(get "#{domain}/issues/1/cover").to route_to("pages#show", issue_id: "1", id: "cover")
      end

      it "routes to #create" do
        expect(post "#{domain}/issues/1/pages").to route_to("pages#create", issue_id: "1")
      end

      it "routes to #update" do
        expect(put "#{domain}/issues/1/cover").to route_to("pages#update", issue_id: "1", id: "cover")
        expect(put "#{domain}/issues/1/pages").to route_to("pages#update", issue_id: "1", id: "pages") # weird
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/issues/1/cover").to route_to("pages#destroy", issue_id: "1", id: "cover")
      end

      it "routes to #add_submission" do
        expect(put "#{domain}/issues/1/cover/add_submission").to \
          route_to("pages#add_submission", issue_id: "1", id: "cover")
      end
    end
    context "when not given a subdomain" do
      let(:domain) { "" }
      it "doesn't route to anything" do
        expect(get "#{domain}/issues/1/cover").not_to route_to("pages#show", issue_id: "1", id: "cover")
        expect(post "#{domain}/issues/1/pages").not_to route_to("pages#create", issue_id: "1")
        expect(put "#{domain}/issues/1/cover").not_to route_to("pages#update", issue_id: "1", id: "cover")
        expect(delete "#{domain}/issues/1/cover").not_to route_to("pages#destroy", issue_id: "1", id: "cover")
      end
    end
  end
end
