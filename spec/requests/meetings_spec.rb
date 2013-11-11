require 'spec_helper'

describe "Meetings" do
  let(:publication) { Factory.create(:publication) }

  describe "GET /meetings/new" do
    it "sets the meeting's meeting to the current publication's current issue" do
      sign_in as: :editor
      issue = Factory.create(:issue, publication: publication)
      visit new_meeting_url(subdomain: publication.subdomain)
      expect(page).to have_selector "select#meeting_issue_id option[selected][value=\"#{issue.id}\"]"
    end
  end

  describe "GET /meetings" do
    context "when the publication has no issues" do
      it "loads meetings only for the current publication" do
        sign_in
        Publication.any_instance.should_receive(:meetings).once.and_return([])
        visit meetings_url(subdomain: publication.subdomain)
      end
    end
  end
end
