require 'spec_helper'

describe "Submissions" do
  describe "GET /submissions" do
    let!(:publications) { [Factory.create(:publication), Factory.create(:publication)] }
    let(:submissions) { [Factory.create(:submission, publication: publications.first),
                       Factory.create(:submission, publication: publications.last)] }
    let(:issues) { [Factory.create(:issue, publication: publications.first, published_on: Time.zone.now - 1.week),
                       Factory.create(:issue, publication: publications.last, published_on: Time.zone.now)] }
    it "only shows submissions from the current publication" do
      submissions # instantiate
      sign_in as: :editor
      visit submissions_url(subdomain: publications.first.subdomain)
      expect(page).to     have_content(submissions.first.title)
      expect(page).not_to have_content(submissions.last .title)
    end
    it "highlights the current issue from the current publication in the sidebar" do
      sign_in as: :editor
      @person.stub(:issues).and_return([issues.last])
      visit submissions_url(subdomain: publications.last.subdomain)
      expect(page).to     have_selector("h3", text: issues.last.title)
    end
    context "when given params[:m] to specify a issue" do
      it "highlights that issue, as long as it's in the current publication" do
        sign_in as: :editor
        @person.stub(:issues).and_return([issues.last])
        visit submissions_url(subdomain: publications.last.subdomain, m: issues.first)
        expect(page).to     have_selector("h3", text: issues.last.title)
      end
    end
  end

  describe "GET /submit" do
    let(:publication) { Factory.create(:publication) }
    context "when signed out" do
      it "assigns the submission to the current publication" do
        visit new_submission_url(subdomain: publication.subdomain)
        expect(page).to have_selector "input#submission_publication_id[value=\"#{publication.id}\"]"
      end
    end
    context "when signed in" do
      it "assigns the submission to the current publication" do
        sign_in
        visit new_submission_url(subdomain: publication.subdomain)
        expect(page).to have_selector "input#submission_publication_id[value=\"#{publication.id}\"]"
      end
    end
  end
end
