require 'spec_helper'

describe Page do
  it {
    should belong_to :issue
    should have_many(:submissions).dependent(:nullify)
    should have_one(:cover_art).dependent(:destroy)
    should have_many(:editors_notes).dependent(:destroy)
    should have_one(:table_of_contents).dependent(:destroy)
    should have_one(:staff_list).dependent(:destroy)

    should validate_presence_of :issue_id
  }

  describe '#title' do
    before :each do
      @issue = Issue.create(
        :accepts_submissions_from  => 6.months.ago,
        :accepts_submissions_until => 1.week.ago,
        :nickname                  => "Fruit Blots"
      )
      @submission = Factory.create(:submission)
      @issue.submissions << @submission
      @issue.publish [@submission]
      @page = @issue.pages.first
    end

    it "has a virtual attribute set to 'position - 4' if nil" do
      @issue.pages.reload.select{|p| p.position == 5}.first.title.should == '1'
    end

    it "does not overwrite a provided title" do
      @issue.pages.create(:title => "one more")
      @issue.pages.select{|p| p.title == "one more"}.should_not be_empty
    end

    context "when the position changes" do
      it "doesn't mess with the titles" do
        toc_original_title = @issue.pages.select{|p| p.position == 4}.first.title
        toc_original_title.should == "ToC"
        page = @issue.pages.create
        page.insert_at(4)
        page.position.should == 4
        page = @issue.pages.reload.last
        page.position.should == 6
        page.title.should == '2'
        toc_original_title.should == @issue.pages.select{|p| p.position == 5}.first.title
      end
    end
  end

  describe "#has_content?" do
    let(:page) { Page.new }

    it "returns false if the page has no submissions, cover art, notes, ToC, or Staff List" do
      page.should_not have_content
    end

    it "returns true if it has submissions" do
      page.stub(:submissions).and_return(1)
      page.should have_content
    end

    it "returns true if it has cover art" do
      page.stub(:cover_art).and_return(1)
      page.should have_content
    end

    it "returns true if it has editors notes" do
      page.stub(:editors_notes).and_return(1)
      page.should have_content
    end

    it "returns true if it has a table of contents" do
      page.stub(:table_of_contents).and_return(1)
      page.should have_content
    end

    it "returns true if it has a staff list" do
      page.stub(:staff_list).and_return(1)
      page.should have_content
    end
  end

  describe "self.with_content" do
    it "returns only pages with content" do
      issue = Factory.create(:issue)
      page1 = Page.create issue: issue
      page2 = Page.create issue: issue
      sub   = Factory.create :submission, state: :published
      page1.submissions << sub
      Page.with_content.should == [page1]
    end
  end

end
