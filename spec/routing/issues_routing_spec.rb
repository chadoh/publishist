require 'spec_helper'

describe IssuesController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "routes to #index at /issues" do
        expect(get "#{domain}/issues").to route_to("issues#index")
      end

      it "routes to #new at /issues/new" do
        expect(get "#{domain}/issues/new").to route_to("issues#new")
      end

      it "routes to #show at /issues/:id" do
        expect(get "#{domain}/issues/dandelion-plum").to route_to("issues#show", id: "dandelion-plum")
      end

      it "routes to #edit at /issues/:id/edit" do
        expect(get "#{domain}/issues/dandelion-plum/edit").to route_to("issues#edit", id: "dandelion-plum")
      end

      it "routes to #create" do
        expect(post "#{domain}/issues").to route_to("issues#create")
      end

      it "routes to #update" do
        expect(put "#{domain}/issues/1").to route_to("issues#update", :id => "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/issues/1").to route_to("issues#destroy", :id => "1")
      end

      it "routes to #highest_scores" do
        expect(get "#{domain}/issues/1/highest_scores").to route_to("issues#highest_scores", :id => "1")
      end

      it "routes to #staff_list" do
        expect(get "#{domain}/issues/1/staff_list").to route_to("issues#staff_list", :id => "1")
      end

      it "routes to #publish" do
        expect(post "#{domain}/issues/1/publish").to route_to("issues#publish", :id => "1")
      end

      it "routes to #notify_authors_of_published_issue" do
        expect(post "#{domain}/issues/1/notify_authors_of_published_issue").to \
          route_to("issues#notify_authors_of_published_issue", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(get "#{domain}/issues").not_to route_to("issues#index")
        expect(get "#{domain}/issues/new").not_to route_to("issues#new")
        expect(get "#{domain}/issues/dandelion-plum").not_to route_to("issues#show")
        expect(get "#{domain}/issues/dandelion-plum/edit").not_to route_to("issues#edit")
        expect(post "#{domain}/issues").not_to route_to("issues#create")
        expect(put "#{domain}/issues/1").not_to route_to("issues#update", :id => "1")
        expect(delete "#{domain}/issues/1").not_to route_to("issues#destroy", :id => "1")
      end
    end
  end
end
