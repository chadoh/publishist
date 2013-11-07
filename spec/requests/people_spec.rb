require 'spec_helper'

describe "People" do

  describe "GET /autocomplete" do
    let!(:publications) { [Factory.create(:publication), Factory.create(:publication)] }
    let!(:people) { [Factory.create(:person, primary_publication_id: publications.first.id),
                     Factory.create(:person, primary_publication_id: publications.last.id)] }

    it "only includes users from the current publication" do
      get autocomplete_people_url(subdomain: publications.first.subdomain, term: "Julia") # the factory names everyone Julia
      expect(response.status).to eq(200)
      expect(response.body).to match(people.first.email)
      expect(response.body).not_to match(people.last.email)
    end
  end

  describe "POST /:id/toggle_default_tips" do
    let(:person) { Factory.create :person, show_tips_at_page_load: true }
    it "toggles #show_tips_at_page_load for the person" do
      post toggle_default_tips_for_person_path(person)
      expect(person.reload.show_tips_at_page_load).to be_false

      post toggle_default_tips_for_person_path(person)
      expect(person.reload.show_tips_at_page_load).to be_true
    end
  end
end
