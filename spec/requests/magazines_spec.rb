require 'spec_helper'

describe "Magazines" do
  describe "GET /magazines" do
    let!(:publications) { [Factory.create(:publication), Factory.create(:publication)] }
    let!(:magazines) { [Factory.create(:magazine, publication: publications.first, published_on: Time.zone.now),
                       Factory.create(:magazine, publication: publications.last, published_on: Time.zone.now)] }
    context "when not signed in" do
      it "only shows magazines from the current publication" do
        visit magazines_url(subdomain: publications.first.subdomain)
        expect(page).to     have_content(magazines.first.title)
        expect(page).not_to have_content(magazines.last .title)
      end
    end

    context "when not signed in" do
      it "only shows magazines from the current publication" do
        sign_in
        visit magazines_url(subdomain: publications.first.subdomain)
        expect(page).to     have_content(magazines.first.title)
        expect(page).not_to have_content(magazines.last .title)
      end
    end
  end

  describe "GET /magazines/new" do
    let(:publication) { Factory.create(:publication) }
    it "sets the magazine's publication to the current publication" do
      sign_in as: :editor
      visit new_magazine_url(subdomain: publication.subdomain)
      expect(page).to have_selector "input#magazine_publication_id[value=\"#{publication.id}\"]"
    end
  end
end
