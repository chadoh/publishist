require 'spec_helper'

describe MeetingsController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "routes to #index at /meetings" do
        expect(get "#{domain}/meetings").to route_to("meetings#index")
      end

      it "routes to #new at /meetings/new" do
        expect(get "#{domain}/meetings/new").to route_to("meetings#new")
      end

      it "routes to #show at /meetings/:id" do
        expect(get "#{domain}/meetings/1").to route_to("meetings#show", id: "1")
      end

      it "routes to #edit at /meetings/:id/edit" do
        expect(get "#{domain}/meetings/1/edit").to route_to("meetings#edit", id: "1")
      end

      it "routes to #create" do
        expect(post "#{domain}/meetings").to route_to("meetings#create")
      end

      it "routes to #update" do
        expect(put "#{domain}/meetings/1").to route_to("meetings#update", :id => "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/meetings/1").to route_to("meetings#destroy", :id => "1")
      end

      it "routes to #scores" do
        expect(get "#{domain}/meetings/1/scores").to route_to("meetings#scores", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(get "#{domain}/meetings").not_to route_to("meetings#index")
        expect(get "#{domain}/meetings/new").not_to route_to("meetings#new")
        expect(get "#{domain}/meetings/1").not_to route_to("meetings#show")
        expect(get "#{domain}/meetings/1/edit").not_to route_to("meetings#edit")
        expect(post "#{domain}/meetings").not_to route_to("meetings#create")
        expect(put "#{domain}/meetings/1").not_to route_to("meetings#update", :id => "1")
        expect(delete "#{domain}/meetings/1").not_to route_to("meetings#destroy", :id => "1")
      end
    end
  end
end
