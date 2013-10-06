require 'spec_helper'

describe "Publications" do
  describe "GET /publications" do
    it "works! (now write some real specs)" do
      get publications_url
      response.status.should be(200)
    end
  end
end
