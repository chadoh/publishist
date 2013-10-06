require 'spec_helper'

describe PackletsController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "doesn't route to #index" do
        expect(get "#{domain}/packlets").not_to route_to("packlets#index")
      end

      it "doesn't route to #new" do
        expect(get "#{domain}/packlets/new").not_to route_to("packlets#new")
      end

      it "doesn't route to #show" do
        expect(get "#{domain}/packlets/1").not_to route_to("packlets#show")
      end

      it "doesn't route to #edit" do
        expect(get "#{domain}/packlets/1/edit").not_to route_to("packlets#edit")
      end

      it "routes to #create" do
        expect(post "#{domain}/packlets").to route_to("packlets#create")
      end

      it "doesn't route to #update" do
        expect(put "#{domain}/packlets/1").not_to route_to("packlets#update")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/packlets/1").to route_to("packlets#destroy", :id => "1")
      end

      it "routes to #update_position" do
        expect(put "#{domain}/packlets/1/update_position").to route_to("packlets#update_position", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(post "#{domain}/packlets").not_to route_to("packlets#create")
        expect(delete "#{domain}/packlets/1").not_to route_to("packlets#destroy", :id => "1")
        expect(put "#{domain}/packlets/1/update_position").not_to route_to("packlets#update_position", :id => "1")
      end
    end
  end
end
