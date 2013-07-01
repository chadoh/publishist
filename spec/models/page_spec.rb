require 'spec_helper'

describe Page do
  it {
    should belong_to :magazine
    should have_many(:submissions).dependent(:nullify)
    should have_one(:cover_art).dependent(:destroy)
    should have_many(:editors_notes).dependent(:destroy)
    should have_one(:table_of_contents).dependent(:destroy)
    should have_one(:staff_list).dependent(:destroy)

    should validate_presence_of :magazine_id
  }

  describe '#title' do
    before :each do
      @magazine = Magazine.create(
        :accepts_submissions_from  => 6.months.ago,
        :accepts_submissions_until => 1.week.ago,
        :nickname                  => "Fruit Blots"
      )
      @submission = Factory.create(:submission)
      @magazine.submissions << @submission
      @magazine.publish [@submission]
      @page = @magazine.pages.first
    end

    it "has a virtual attribute set to 'position - 4' if nil" do
      @magazine.pages.reload.select{|p| p.position == 5}.first.title.should == '1'
    end

    it "does not overwrite a provided title" do
      @magazine.pages.create(:title => "one more")
      @magazine.pages.select{|p| p.title == "one more"}.should_not be_empty
    end

    context "when the position changes" do
      it "doesn't mess with the titles" do
        toc_original_title = @magazine.pages.select{|p| p.position == 4}.first.title
        toc_original_title.should == "ToC"
        page = @magazine.pages.create
        page.insert_at(4)
        page.position.should == 4
        page = @magazine.pages.reload.last
        page.position.should == 6
        page.title.should == '2'
        toc_original_title.should == @magazine.pages.select{|p| p.position == 5}.first.title
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
      magazine = Factory.create(:magazine)
      page1 = Page.create magazine: magazine
      page2 = Page.create magazine: magazine
      sub   = Factory.create :submission, state: :published
      page1.submissions << sub
      Page.with_content.should == [page1]
    end
  end

end
