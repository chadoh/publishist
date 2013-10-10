require 'spec_helper'

describe "Submissions" do
  describe "GET /submissions" do
    let!(:publications) { [Factory.create(:publication), Factory.create(:publication)] }
    let(:submissions) { [Factory.create(:submission, publication: publications.first),
                       Factory.create(:submission, publication: publications.last)] }
    let(:magazines) { [Factory.create(:magazine, publication: publications.first, published_on: Time.zone.now - 1.week),
                       Factory.create(:magazine, publication: publications.last, published_on: Time.zone.now)] }
    it "only shows submissions from the current publication" do
      submissions # instantiate
      sign_in as: :editor
      visit submissions_url(subdomain: publications.first.subdomain)
      expect(page).to     have_content(submissions.first.title)
      expect(page).not_to have_content(submissions.last .title)
    end
    it "highlights the current issue from the current publication in the sidebar" do
      sign_in as: :editor
      @person.stub(:magazines).and_return([magazines.last])
      visit submissions_url(subdomain: publications.last.subdomain)
      expect(page).to     have_selector("h3", text: magazines.last.title)
    end
    context "when given params[:m] to specify a magazine" do
      it "highlights that magazine, as long as it's in the current publication" do
        sign_in as: :editor
        @person.stub(:magazines).and_return([magazines.last])
        visit submissions_url(subdomain: publications.last.subdomain, m: magazines.first)
        expect(page).to     have_selector("h3", text: magazines.last.title)
      end
    end
  end
end
