require 'spec_helper'

describe "Meetings" do
  describe "GET /meetings/new" do
    let(:publication) { Factory.create(:publication) }
    it "sets the meeting's meeting to the current publication's current magazine" do
      sign_in as: :editor
      magazine = Factory.create(:magazine, publication: publication)
      visit new_meeting_url(subdomain: publication.subdomain)
      expect(page).to have_selector "select#meeting_magazine_id option[selected][value=\"#{magazine.id}\"]"
    end
  end
end
