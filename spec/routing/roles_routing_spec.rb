require 'spec_helper'

describe RolesController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "doesn't route to #index, #show, #edit, or #update" do
        expect(get "#{domain}/roles").not_to route_to("roles#index")
        expect(get "#{domain}/roles/1").not_to route_to("roles#show")
        expect(get "#{domain}/roles/1/edit").not_to route_to("roles#edit")
        expect(put "#{domain}/roles/1").not_to route_to("roles#update")
      end

      it "routes to #new" do
        expect(get "#{domain}/roles/new").to route_to("roles#new")
      end

      it "routes to #create" do
        expect(post "#{domain}/roles").to route_to("roles#create")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/roles/1").to route_to("roles#destroy", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(get "#{domain}/roles/new").not_to route_to("roles#new")
        expect(post "#{domain}/roles").not_to route_to("roles#create")
        expect(delete "#{domain}/roles/1").not_to route_to("roles#destroy")
      end
    end
  end
end
