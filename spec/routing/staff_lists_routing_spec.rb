require 'spec_helper'

describe ScoresController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "doesn't route to #index, #new, #show, or #edit" do
        expect(get "#{domain}/scores").not_to route_to("scores#index")
        expect(get "#{domain}/scores/new").not_to route_to("scores#new")
        expect(get "#{domain}/scores/1").not_to route_to("scores#show")
        expect(get "#{domain}/scores/1/edit").not_to route_to("scores#edit")
      end

      it "routes to #create" do
        expect(post "#{domain}/scores").to route_to("scores#create")
      end

      it "routes to #update" do
        expect(put "#{domain}/scores/1").to route_to("scores#update", id: "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/scores/1").to route_to("scores#destroy", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(post "#{domain}/scores").not_to route_to("scores#create")
        expect(put "#{domain}/scores/1").not_to route_to("scores#update", id: "1")
        expect(delete "#{domain}/scores/1").not_to route_to("scores#destroy")
      end
    end
  end
end
