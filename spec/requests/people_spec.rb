require 'spec_helper'

describe "People" do
  let!(:publications) { [Factory.create(:publication), Factory.create(:publication)] }
  let!(:people) { [Factory.create(:person, primary_publication_id: publications.first.id),
                   Factory.create(:person, primary_publication_id: publications.last.id)] }

  describe "GET /autocomplete" do
    it "only includes users from the current publication" do
      get autocomplete_people_url(subdomain: publications.first.subdomain, term: "Julia") # the factory names everyone Julia
      expect(response.status).to eq(200)
      expect(response.body).to match(people.first.email)
      expect(response.body).not_to match(people.last.email)
    end
  end
end
