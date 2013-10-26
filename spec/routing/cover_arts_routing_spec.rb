require 'spec_helper'

describe CoverArtsController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "doesn't route to #index, #new, #show, #edit, or #update" do
        expect(get "#{domain}/cover_arts").not_to route_to("cover_arts#index")
        expect(get "#{domain}/cover_arts/new").not_to route_to("cover_arts#new")
        expect(get "#{domain}/cover_arts/1").not_to route_to("cover_arts#show")
        expect(get "#{domain}/cover_arts/1/edit").not_to route_to("cover_arts#edit")
        expect(put "#{domain}/cover_arts/1").not_to route_to("cover_arts#update")
      end

      it "routes to #create" do
        expect(post "#{domain}/cover_arts").to route_to("cover_arts#create")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/cover_arts/1").to route_to("cover_arts#destroy", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(post "#{domain}/cover_arts").not_to route_to("cover_arts#create")
        expect(delete "#{domain}/cover_arts/1").not_to route_to("cover_arts#destroy")
      end
    end
  end
end
