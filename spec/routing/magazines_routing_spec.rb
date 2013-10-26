require 'spec_helper'

describe MagazinesController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "routes to #index at /magazines" do
        expect(get "#{domain}/magazines").to route_to("magazines#index")
      end

      it "routes to #new at /magazines/new" do
        expect(get "#{domain}/magazines/new").to route_to("magazines#new")
      end

      it "routes to #show at /magazines/:id" do
        expect(get "#{domain}/magazines/dandelion-plum").to route_to("magazines#show", id: "dandelion-plum")
      end

      it "routes to #edit at /magazines/:id/edit" do
        expect(get "#{domain}/magazines/dandelion-plum/edit").to route_to("magazines#edit", id: "dandelion-plum")
      end

      it "routes to #create" do
        expect(post "#{domain}/magazines").to route_to("magazines#create")
      end

      it "routes to #update" do
        expect(put "#{domain}/magazines/1").to route_to("magazines#update", :id => "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/magazines/1").to route_to("magazines#destroy", :id => "1")
      end

      it "routes to #highest_scores" do
        expect(get "#{domain}/magazines/1/highest_scores").to route_to("magazines#highest_scores", :id => "1")
      end

      it "routes to #staff_list" do
        expect(get "#{domain}/magazines/1/staff_list").to route_to("magazines#staff_list", :id => "1")
      end

      it "routes to #publish" do
        expect(post "#{domain}/magazines/1/publish").to route_to("magazines#publish", :id => "1")
      end

      it "routes to #notify_authors_of_published_magazine" do
        expect(post "#{domain}/magazines/1/notify_authors_of_published_magazine").to \
          route_to("magazines#notify_authors_of_published_magazine", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(get "#{domain}/magazines").not_to route_to("magazines#index")
        expect(get "#{domain}/magazines/new").not_to route_to("magazines#new")
        expect(get "#{domain}/magazines/dandelion-plum").not_to route_to("magazines#show")
        expect(get "#{domain}/magazines/dandelion-plum/edit").not_to route_to("magazines#edit")
        expect(post "#{domain}/magazines").not_to route_to("magazines#create")
        expect(put "#{domain}/magazines/1").not_to route_to("magazines#update", :id => "1")
        expect(delete "#{domain}/magazines/1").not_to route_to("magazines#destroy", :id => "1")
      end
    end
  end
end
