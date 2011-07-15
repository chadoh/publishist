require 'spec_helper'

describe Page do
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

  it {
    should belong_to :magazine
    should have_many(:submissions).dependent(:nullify)
    should have_one(:cover_art).dependent(:destroy)

    should validate_presence_of :magazine_id
  }

  describe '#title' do
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

end
