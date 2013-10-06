require 'spec_helper'

describe SubmissionsController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "routes to #index at /submissions" do
        expect(get "#{domain}/submissions").to route_to("submissions#index")
      end

      it "routes to #new at /submit" do
        expect(get "#{domain}/submit").to route_to("submissions#new")
        expect(get "#{domain}/submissions/new").not_to route_to("submissions#new")
      end

      it "routes to #show at /:submission_id" do
        expect(get "#{domain}/dandelion-plum").to route_to("submissions#show", id: "dandelion-plum")
        expect(get "#{domain}/submissions/dandelion-plum").not_to route_to("submissions#show")
      end

      it "routes to #edit at /:submission_id/edit" do
        expect(get "#{domain}/dandelion-plum/edit").to route_to("submissions#edit", id: "dandelion-plum")
        expect(get "#{domain}/submissions/dandelion-plum/edit").not_to route_to("submissions#edit")
      end

      it "routes to #create" do
        expect(post "#{domain}/submissions").to route_to("submissions#create")
      end

      it "routes to #update" do
        expect(put "#{domain}/1").to route_to("submissions#update", :id => "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/1").to route_to("submissions#destroy", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(get "#{domain}/submissions").not_to route_to("submissions#index")
        expect(get "#{domain}/submit").not_to route_to("submissions#new")
        expect(get "#{domain}/dandelion-plum").not_to route_to("submissions#show", id: "dandelion-plum")
        expect(get "#{domain}/dandelion-plum/edit").not_to route_to("submissions#edit", id: "dandelion-plum")
        expect(post "#{domain}/submissions").not_to route_to("submissions#create")
        expect(put "#{domain}/submissions/1").not_to route_to("submissions#update", :id => "1")
        expect(delete "#{domain}/submissions/1").not_to route_to("submissions#destroy", :id => "1")
      end
    end
  end
end
