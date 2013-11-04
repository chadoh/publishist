require 'spec_helper'

describe "Meetings" do
  let(:publication) { Factory.create(:publication) }

  describe "GET /meetings/new" do
    it "sets the meeting's meeting to the current publication's current magazine" do
      sign_in as: :editor
      magazine = Factory.create(:magazine, publication: publication)
      visit new_meeting_url(subdomain: publication.subdomain)
      expect(page).to have_selector "select#meeting_magazine_id option[selected][value=\"#{magazine.id}\"]"
    end
  end

  describe "GET /meetings" do
    context "when the publication has no magazines" do
      it "loads meetings only for the current publication" do
        sign_in
        Publication.any_instance.should_receive(:meetings).once.and_return([])
        visit meetings_url(subdomain: publication.subdomain)
      end
    end
  end
end
