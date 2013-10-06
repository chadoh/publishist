require 'spec_helper'

describe PeopleController do
  describe "routing" do
    context "when on a subdomain" do
      let(:domain) { "http://pc.publishist.test" }

      it "doesn't route to #index" do
        expect(get "#{domain}/people").not_to route_to("people#index")
      end

      it "routes to #new with /sign_up, and uses the people/registrations controller" do
        expect(get "#{domain}/sign_up").to route_to("people/registrations#new")
        expect(get "#{domain}/people/new").not_to route_to("people#new")
        expect(get "#{domain}/people/new").not_to route_to("people/registrations#new")
      end

      it "routes to #create with the people/registrations controller" do
        expect(post "#{domain}/people").to route_to("people/registrations#create")
      end

      it "routes to #show" do
        expect(get "#{domain}/people/1").to route_to("people#show", id: "1")
      end

      it "routes to #edit" do
        expect(get "#{domain}/people/1/edit").to route_to("people#edit", id: "1")
      end

      it "routes to #update" do
        expect(put "#{domain}/people/1").to route_to("people#update", id: "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/people/1").to route_to("people#destroy", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "still all works fine" do
        expect(get "#{domain}/sign_up").to route_to("people/registrations#new")
        expect(post "#{domain}/people").to route_to("people/registrations#create")
        expect(get "#{domain}/people/1/edit").to route_to("people#edit", id: "1")
        expect(put "#{domain}/people/1").to route_to("people#update", id: "1")
        expect(delete "#{domain}/people/1").to route_to("people#destroy", id: "1")
      end
    end
  end
end
