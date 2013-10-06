require 'spec_helper'

describe TableOfContentsController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "doesn't route to #index, #new, #show, #edit, or #update" do
        expect(get "#{domain}/table_of_contents").not_to route_to("table_of_contents#index")
        expect(get "#{domain}/table_of_contents/new").not_to route_to("table_of_contents#new")
        expect(get "#{domain}/table_of_contents/1").not_to route_to("table_of_contents#show")
        expect(get "#{domain}/table_of_contents/1/edit").not_to route_to("table_of_contents#edit")
        expect(put "#{domain}/table_of_contents/1").not_to route_to("table_of_contents#update")
      end

      it "routes to #create" do
        expect(post "#{domain}/table_of_contents").to route_to("table_of_contents#create")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/table_of_contents/1").to route_to("table_of_contents#destroy", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(post "#{domain}/table_of_contents").not_to route_to("table_of_contents#create")
        expect(delete "#{domain}/table_of_contents/1").not_to route_to("table_of_contents#destroy")
      end
    end
  end
end
