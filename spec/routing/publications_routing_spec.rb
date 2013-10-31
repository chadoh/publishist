require "spec_helper"

describe PublicationsController do
  describe "routing" do

    context "when given a generic subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "doesn't route to #index or #new" do
        expect(get "#{domain}/publications").not_to route_to("publications#index")
        expect(get "#{domain}/publications/new").not_to route_to("publications#new")
      end

      it "routes to #show at /" do
        expect(get "#{domain}/").to route_to("publications#show")
      end

      it "routes to #edit at /publications/:id/edit" do
        expect(get "#{domain}/publications/1/edit").to route_to("publications#edit", id: "1")
      end

      it "routes to #create" do
        expect(post "#{domain}/publications").to route_to("publications#create")
      end

      it "routes to #update" do
        expect(put "#{domain}/publications/1").to route_to("publications#update", :id => "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/publications/1").to route_to("publications#destroy", :id => "1")
      end
    end
    context "when given a subdomain of 'secret-sign-up'" do
      let(:domain) { "http://secret-sign-up.example.com" }
      it "routes to #new at /" do
        expect(get "#{domain}/").to route_to("publications#new")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(get "#{domain}/publications").not_to route_to("publications#index")
        expect(get "#{domain}/publications/new").not_to route_to("publications#new")
        expect(get "#{domain}/publications/1").not_to route_to("publications#show")
        expect(get "#{domain}/publications/1/edit").not_to route_to("publications#edit")
        expect(post "#{domain}/publications").not_to route_to("publications#create")
        expect(put "#{domain}/publications/1").not_to route_to("publications#update", :id => "1")
        expect(delete "#{domain}/publications/1").not_to route_to("publications#destroy", :id => "1")
      end
    end
  end
end
