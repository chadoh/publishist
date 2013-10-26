require "spec_helper"

describe PublicationsController do
  describe "routing" do

    it "does not route to #index" do
      get("/publications").should_not route_to("publications#index")
      get("/").should_not route_to("publications#index")
    end

    it "routes to #new" do
      get("/publications/new").should route_to("publications#new")
    end

    it "routes to #show with a subdomain only" do
      expect(get "http://pc.example.com/").to route_to("publications#show")
      expect(get "/publications/1").not_to route_to("publications#show")
    end

    it "routes to #edit" do
      get("/publications/1/edit").should route_to("publications#edit", :id => "1")
    end

    it "routes to #create" do
      post("/publications").should route_to("publications#create")
    end

    it "routes to #update" do
      put("/publications/1").should route_to("publications#update", :id => "1")
    end

    it "routes to #destroy" do
      delete("/publications/1").should route_to("publications#destroy", :id => "1")
    end

  end
end
