require 'spec_helper'

describe "Creating An Account" do
  let(:publication) { Factory.create(:publication) }
  let(:magazine) { Factory.create(:magazine, publication: publication) }
  let(:meeting) { Factory.create(:meeting, magazine: magazine) }

  describe "when using the sign up form on a subdomain" do
    it "associates the newcomer with the given publication" do
      visit sign_up_url(subdomain: publication.subdomain)
      fill_in "person_name", with: "Cleetus Browtopper"
      fill_in "person_email", with: "browtopper@cleet.us"
      click_button "Sign Up"
      person = Person.first
      expect(person.primary_publication).to eq(publication)
      expect(publication.people).to eq([person])
    end
  end
  describe "when submitting while not signed in (with an unknown email address)" do
    it "creates an account for the newcomer, and associates them with the publication they submitted to" do
      visit new_submission_url(subdomain: publication.subdomain)
      fill_in "submission_title", with: "Woo"
      fill_in "submission_body", with: "Tang"
      fill_in "submission_author_name", with: "Cleetus Browtopper"
      fill_in "submission_author_email", with: "browtopper@cleet.us"
      click_button "Submit"
      person = Person.first
      expect(person.primary_publication).to eq(publication)
      expect(publication.people).to eq([person])
    end
  end
  describe "when an editor signs someone up from the new submission page" do
    it "associates that person with the editor's publication" do
      sign_in as: :editor
      visit new_submission_url(subdomain: publication.subdomain)
      fill_in "submission_title", with: "Woo"
      fill_in "submission_body", with: "Tang"
      fill_in "submission_author", with: "Cleetus Bowergrave, bowergrave@cleet.us"
      click_button "Submit"
      person = Person.last
      expect(person.primary_publication).to eq(publication)
      expect(publication.people).to eq([person])
    end
  end
  describe "when an editor signs someone up from the meeting page" do
    it "associates that person with the editor's publication" do
      sign_in as: :editor
      visit meeting_url(meeting, subdomain: publication.subdomain)
      fill_in "attendee_person", with: "Cleetus Simonectus, simonectus@cleet.us"
      click_button "Add"
      person = Person.last
      expect(person.primary_publication_id).to eq(publication.id)
      expect(publication.people).to eq([person])
    end
  end
  describe "when an editor signs someone up from the staff list" do
    let!(:position) { Factory.create(:position, magazine: magazine) }
    it "associates that person with the editor's publication" do
      sign_in as: :editor
      visit staff_for_magazine_url(magazine, subdomain: publication.subdomain)
      fill_in "role_person", with: "Cleetus Horald, horald@cleet.us"
      click_button "Save"
      person = Person.last
      expect(person.primary_publication).to eq(publication)
      expect(publication.people).to eq([person])
    end
  end
end
