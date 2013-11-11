require 'spec_helper'

describe "Issues" do
  describe "GET /issues" do
    let!(:publications) { [Factory.create(:publication), Factory.create(:publication)] }
    let!(:issues) { [Factory.create(:issue, publication: publications.first, published_on: Time.zone.now),
                       Factory.create(:issue, publication: publications.last, published_on: Time.zone.now)] }
    context "when not signed in" do
      it "only shows issues from the current publication" do
        visit issues_url(subdomain: publications.first.subdomain)
        expect(page).to     have_content(issues.first.title)
        expect(page).not_to have_content(issues.last .title)
      end
    end

    context "when signed in" do
      it "only shows issues from the current publication" do
        sign_in
        visit issues_url(subdomain: publications.first.subdomain)
        expect(page).to     have_content(issues.first.title)
        expect(page).not_to have_content(issues.last .title)
      end
    end
  end

  describe "GET /issues/new" do
    let(:publication) { Factory.create(:publication) }
    it "sets the issue's publication to the current publication" do
      sign_in as: :editor
      visit new_issue_url(subdomain: publication.subdomain)
      expect(page).to have_selector "input#issue_publication_id[value=\"#{publication.id}\"]"
    end
  end
end
