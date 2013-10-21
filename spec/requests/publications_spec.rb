require 'spec_helper'

describe "Publications" do
  describe "GET /publications" do
    it "works" do
      get publications_url
      response.status.should be(200)
    end
  end

  describe "GET \#{publication.subdomain}.publishist.com" do
    it "loads up a random published submission from the publication and info about the publication" do
      publication = Factory.create(:publication)
      magazine = Factory.create(:magazine, publication: publication, published_on: Date.yesterday, notification_sent: true)
      submission = Factory.create(:submission, publication: publication, magazine: magazine, state: :published)

      visit root_url(subdomain: publication.subdomain)
      expect(page).to have_content(submission.title)
      expect(page).to have_content(publication.about)
    end
  end
end
