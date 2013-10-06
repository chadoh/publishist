require 'spec_helper'

describe EditorsNotesController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "doesn't route to #index or #show" do
        expect(get "#{domain}/editors_notes").not_to route_to("editors_notes#index")
        expect(get "#{domain}/editors_notes/1").not_to route_to("editors_notes#show")
      end

      it "routes to #new" do
        expect(get "#{domain}/editors_notes/new").to route_to("editors_notes#new")
      end
      it "routes to #create" do
        expect(post "#{domain}/editors_notes").to route_to("editors_notes#create")
      end

      it "routes to #edit" do
        expect(get "#{domain}/editors_notes/1/edit").to route_to("editors_notes#edit", id: "1")
      end

      it "routes to #update" do
        expect(put "#{domain}/editors_notes/1").to route_to("editors_notes#update", id: "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/editors_notes/1").to route_to("editors_notes#destroy", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(get "#{domain}/editors_notes/new").not_to route_to("editors_notes#new")
        expect(post "#{domain}/editors_notes").not_to route_to("editors_notes#create")
        expect(get "#{domain}/editors_notes/1/edit").not_to route_to("editors_notes#edit", id: "1")
        expect(put "#{domain}/editors_notes/1").not_to route_to("editors_notes#update", id: "1")
        expect(delete "#{domain}/editors_notes/1").not_to route_to("editors_notes#destroy")
      end
    end
  end
end
