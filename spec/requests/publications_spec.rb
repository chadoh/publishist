require 'spec_helper'

describe "Publications" do
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
  describe "GET \#{some unrecognized subdomain}.publishist.com" do
    it "renders 404" do
      expect { visit root_url(subdomain: "nonsense") }.to raise_error(ActionController::RoutingError)
    end
  end
  describe "POST some-subdomain.publishist.com" do
    let(:email) { "hello@there.you" }
    let(:name) { "Fancy Prance" }
    let(:editor) { Person.find_by_email(email) }
    let(:publication) { Publication.find_by_name(name) }
    before do
      post "http://whatever.publishist.dev/publications", "publication_name" => name, "editor_email" => email
      Person.any_instance.stub(:orchestrates?).and_return(false)
    end
    it "creates a publication, an editor, sample data, and signs the editor in" do
      expect(Publication.count).to eq 1
      expect(publication.people.count).to eq 2

      expect(response).to redirect_to("http://#{name.downcase.tr(' ','')}.publishist.dev/")
      follow_redirect!
      expect(response.body).to match email
      expect(response.body).to match "seeding"

      expect(publication.editor).to eq editor

      expect(Magazine.count).not_to eq 0
      expect(Submission.count).not_to eq 0
      expect(Meeting.count).not_to eq 0
    end
  end
end
