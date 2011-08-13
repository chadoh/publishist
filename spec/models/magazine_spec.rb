require 'spec_helper'

describe Magazine do
  it {
    should validate_presence_of :nickname
    should validate_presence_of :accepts_submissions_from
    should validate_presence_of :accepts_submissions_until
    should have_many(:meetings).dependent(:nullify)
    should have_many(:pages).dependent(:destroy)
    should have_many(:cover_arts).through(:pages)
  }

  describe "#cover_art" do
    it "returns the first cover art (which should be the only one...)" do
      mag = Magazine.create(
        accepts_submissions_from:  5.months.ago,
        accepts_submissions_until: Date.yesterday
      )
      mag.publish []
      mag.cover_art.should == CoverArt.first
    end
  end

  describe "#nickname" do
    it "defaults to 'next'" do
      mag = Magazine.new
      mag.nickname.should == "next"
    end
  end

  describe "#notification_sent" do
    it "defaults to 'false'" do
      mag = Magazine.new
      mag.notification_sent?.should be_false
    end
  end

  describe "#accepts_submissions_from" do
    context "when this is the first magazine" do
      it "defaults to today" do
        mag = Magazine.new
        mag2 = Magazine.new :accepts_submissions_from => Date.today
        mag.accepts_submissions_from.should == mag2.accepts_submissions_from
      end
    end

    context "when there are other magazines" do
      it "defaults to the accepts_submissions_until date of the latest magazine" do
        mag = Magazine.create
        mag2 = Magazine.new
        mag2.accepts_submissions_from.should == mag.accepts_submissions_until
      end
    end

    it "cannot fall within another magazine's range" do
      orig = Magazine.create
      mag = Magazine.new :accepts_submissions_from => orig.accepts_submissions_from + 1.day
      mag.should_not be_valid
    end
  end

  describe "#accepts_submissions_until" do
    it "defaults to six months after accepts_submissions_from" do
      mag = Magazine.create
      mag.accepts_submissions_until.should == mag.accepts_submissions_from + 6.months
      # need to test another one, since the way `from` initializes changes with subsequent mags
      mag2 = Magazine.new
      mag2.accepts_submissions_until.should == mag2.accepts_submissions_from + 6.months
    end

    it "must be > self.accepts_submissions_from" do
      mag = Magazine.new(
        :accepts_submissions_from  => Date.today,
        :accepts_submissions_until => Date.yesterday
      )
      mag.should_not be_valid
    end

    it "cannot fall within another magazine's range" do
      orig = Magazine.create
      mag = Magazine.new(
        :accepts_submissions_until => orig.accepts_submissions_until - 1.day,
        :accepts_submissions_from => Date.yesterday
      )
      mag.should_not be_valid

      orig.accepts_submissions_until = orig.accepts_submissions_until - 1.day
      orig.should be_valid
    end
  end

  describe "with the default settings" do
    it "should be valid" do
      Magazine.new.should be_valid
    end
  end

  describe "#average_score" do
    it "returns the average score for the submissions in this magazine" do
      mag      = Factory.create :magazine
      mag2     = Factory.create :magazine
      meeting  = Meeting.create(:datetime => Date.tomorrow) # in mag
      meeting2 = Meeting.create(:datetime => Date.tomorrow + 6.months) # in mag2
      sub      = Factory.create :submission
      sub2     = Factory.create :submission
      p        = Factory.create :person
      p2       = Factory.create :person
      a        = Attendee.create :meeting => meeting, :person => p
      a2       = Attendee.create :meeting => meeting, :person => p2
      a3       = Attendee.create :meeting => meeting2, :person => p
      a4       = Attendee.create :meeting => meeting2, :person => p2
      packlet  = Packlet.create  :meeting => meeting, :submission => sub
      packlet2 = Packlet.create  :meeting => meeting2, :submission => sub2
      packlet.scores << [Score.create('amount' => 5, :attendee => a), Score.create('amount' => 4, :attendee => a2)]
      packlet2.scores << [Score.create('amount' => 10, :attendee => a3), Score.create('amount' => 10, :attendee => a4)]
      mag.reload.average_score.should == 4.5
    end
  end

  describe ".current" do
    it "returns the magazine that accepts submissions at the current date" do
      mag  = Magazine.create :accepts_submissions_from => Date.yesterday,
                            :accepts_submissions_until => Date.tomorrow
      mag2 = Magazine.create
      Magazine.current.should == mag
    end
  end

  def a_magazine_has_just_finished options = {}
    @mag      = Magazine.create(
      :nickname => "Diner",
      :title    => "A Problematic Late-Night Diner",
      :accepts_submissions_until => Date.yesterday,
      :accepts_submissions_from  => 6.months.ago
    )
    @sub      = Factory.create :anonymous_submission
    @sub2     = Factory.create :anonymous_submission
    @meeting  = Meeting.create(:datetime => Date.yesterday) # in mag
    packlet  = Packlet.create  :meeting => @meeting, :submission => @sub
    packlet2 = Packlet.create  :meeting => @meeting, :submission => @sub2
    if options[:include_scores].present?
      p        = Factory.create :person
      p2       = Factory.create :person
      a        = Attendee.create :meeting => @meeting, :person => p
      a2       = Attendee.create :meeting => @meeting, :person => p2
      packlet.scores << [Score.create(:amount => 6, :attendee => a), Score.create(:amount => 4, :attendee => a2)]
      packlet2.scores << [Score.create(:amount => 10, :attendee => a), Score.create(:amount => 10, :attendee => a2)]
    end
  end

  describe "#highest_scores(how_many)" do
    it "returns the highest-scoring submissions for the magazine" do
      a_magazine_has_just_finished include_scores: true
      @mag.highest_scores(1).should == [@sub2]
    end

    it "does not barf when a submission's scores are nil" do
      a_magazine_has_just_finished
      Score.delete_all; Submission.update_all :state => Submission.state(:reviewed)
      @mag.reload.highest_scores.should be_empty
    end
  end

  describe "#all_scores_above(this_score)" do
    it "returns all submissions scored above the given score" do
      a_magazine_has_just_finished include_scores: true
      @mag.all_scores_above(6).should == [@sub2]
    end
  end

  describe "#present_name" do
    let(:mag) { Factory.create :magazine }

    it "returns just the magazine title, if it's set" do
      mag.present_name.should == mag.title
    end

    it "returns 'the <nickname> magazine' if the title isn't set" do
      mag.title = nil
      mag.present_name.should == "the #{mag.nickname} magazine"
    end
  end

  describe "#publish(array_of_winners)" do
    it "returns an error if the magazine's end-date for submissions has not yet passed" do
      mag = Factory.create :magazine
      expect { mag.publish [] }.to raise_error
    end

    context "when called correctly" do
      before do
        a_magazine_has_just_finished
        @mag.publish [@sub2]
      end

      it "sets the published_on date for the magazine to the current date" do
        @mag.published_on.to_date.should == Date.today
      end

      it "sets checked magazines to published and the rest to rejected" do
        @sub.reload.should be_rejected
        @sub2.reload.should be_published
      end

      it "creates 5 pages at minimum: 1 for cover, 1 for Notes, 1 for Staff, 1 for ToC, and 1 per 5 submissions after that" do
        @mag.pages.length.should == 5
      end
    end
  end

  describe "#notify_authors_of_published_magazine" do
    it "emails all of the authors who submitted for this magazine to let them know which (if any) of their submissions made it, and sets notification_sent to true for the magazine" do
      a_magazine_has_just_finished
      mock_mail = mock(:mail)
      mock_mail.stub(:deliver)
      @mag.publish [@sub2]
      @mag.submissions(:reload)
      [@sub, @sub2].each do |sub|
        Notifications.should_receive(:we_published_a_magazine).with(sub.email, @mag, [sub]).and_return(mock_mail)
      end
      @mag.notify_authors_of_published_magazine
      @mag.notification_sent?.should be_true
    end
  end

  describe "#published?" do
    let (:mag) { Factory.create :magazine }

    it "returns false if the magazine has no published_on value" do
      mag.should_not be_published
    end

    it "returns true if the magazine has a published_on value" do
      mag.update_attribute :published_on, Date.today
      mag.should be_published
    end
  end

  describe "a published magazine" do
    before do
      a_magazine_has_just_finished
      @mag.publish [@sub2]
    end

    describe "#page" do
      it "queries a mag's pages by the pages' titles (or pseudo titles)" do
        @mag.page('Cover').position.should == 1
        page = @mag.page('1').submissions.should == [@sub2]
      end

      it "if the provided page is nil, it provides the first page" do
        @mag.page(nil).position.should == 1
      end
    end

    describe "#create_page_at" do
      it "creates a page and inserts it at the supplied position, returning the page" do
        page = @mag.create_page_at(3)
        page.position.should == 3
      end

      it "creates a page but doesn't insert it anywhere if the supplied value is blank" do
        page = @mag.create_page_at("")
        page[:title].should be_blank
      end
    end
  end

  describe "#submissions" do
    before do
      a_magazine_has_just_finished
    end

    it "returns a scope, not an array" do
      @mag.submissions.class.should == ActiveRecord::Relation
    end

    it "returns submissions for the specified magazine, not some other magazine" do
      mag2 = Magazine.create(:nickname => "Poopty poopty pants")
      meeting = Meeting.create(:datetime => 1.week.from_now)
      sub = Factory.create :submission
      meeting.submissions << sub
      mag2.submissions.should == [sub]
      @mag.submissions.should_not include(sub)
    end

    it "memoizes the result" do
      @mag.submissions # this result should now be memoized

      sub3 = Factory.create :submission
      @meeting.submissions << sub3
      @mag.reload.submissions.should_not include(sub3)
    end

    context "when the magazine has been published" do
      it "only returns published submissions" do
        @mag.update_attribute :published_on, Date.today
        @mag.submissions.should be_blank
        @sub.has_been(:published)
        @mag.reload.submissions.should include(@sub)
      end
    end
  end

end
