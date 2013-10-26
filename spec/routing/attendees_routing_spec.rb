require 'spec_helper'

describe AttendeesController do
  describe "routing" do
    context "when given a subdomain" do
      let(:domain) { "http://pc.publishist.test" }
      it "doesn't route to #show or #index" do
        expect(get "#{domain}/meetings/1/attendees/1").not_to route_to("attendees#show")
        expect(get "#{domain}/meetings/1/attendees").not_to route_to("attendees#index")
      end

      it "routes to #edit" do
        expect(get "#{domain}/meetings/1/attendees/1/edit").to route_to("attendees#edit", meeting_id: "1", id: "1")
      end

      it "routes to #create" do
        expect(post "#{domain}/meetings/1/attendees").to route_to("attendees#create", meeting_id: "1")
      end

      it "routes to #update" do
        expect(put "#{domain}/meetings/1/attendees/1").to route_to("attendees#update", meeting_id: "1", id: "1")
      end

      it "routes to #destroy" do
        expect(delete "#{domain}/meetings/1/attendees/1").to route_to("attendees#destroy", meeting_id: "1", id: "1")
      end

      it "routes to #update_answer" do
        expect(put "#{domain}/meetings/1/attendees/1/update_answer").to \
          route_to("attendees#update_answer", meeting_id: "1", id: "1")
      end
    end
    context "when not given a subdomain" do
      let(:domain) { "" }
      it "doesn't route to anything" do
        expect(post "#{domain}/meetings/1/attendees").not_to route_to("attendees#create")
        expect(put "#{domain}/meetings/1/attendees/1").not_to route_to("attendees#update")
        expect(delete "#{domain}/meetings/1/attendees/1").not_to route_to("attendees#destroy")
      end
    end
  end
end
