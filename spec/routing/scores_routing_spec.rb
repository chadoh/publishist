require 'spec_helper'

describe StaffListsController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.example.com" }

      it "doesn't route to #index, #new, #show, #edit, or #update" do
        expect(get "#{domain}/staff_lists").not_to route_to("staff_lists#index")
        expect(get "#{domain}/staff_lists/new").not_to route_to("staff_lists#new")
        expect(get "#{domain}/staff_lists/1").not_to route_to("staff_lists#show")
        expect(get "#{domain}/staff_lists/1/edit").not_to route_to("staff_lists#edit")
        expect(put "#{domain}/staff_lists/1").not_to route_to("staff_lists#update")
      end

      it "routes to #create" do
        expect(post "#{domain}/staff_lists").to route_to("staff_lists#create")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/staff_lists/1").to route_to("staff_lists#destroy", :id => "1")
      end
    end
    context "when given no subdomain" do
      let(:domain) { "" }

      it "doesn't route to anything" do
        expect(post "#{domain}/staff_lists").not_to route_to("staff_lists#create")
        expect(delete "#{domain}/staff_lists/1").not_to route_to("staff_lists#destroy")
      end
    end
  end
end
