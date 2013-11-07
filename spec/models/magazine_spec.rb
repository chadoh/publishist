require 'spec_helper'

describe Magazine do
  let(:publications) { [Factory.create(:publication), Factory.create(:publication)] }

  it {
    should validate_presence_of :nickname
    should validate_presence_of :accepts_submissions_from
    should validate_presence_of :accepts_submissions_until
    should have_many(:meetings).dependent(:nullify)
    should have_many(:pages).dependent(:destroy)
    should have_many(:positions).dependent(:destroy)
    should have_many(:roles).through(:positions)
    should belong_to(:publication)
  }

  describe ".published" do
    it "returns only magazines that've been published and that have had their notification sent" do
      magazines = [Factory.create(:magazine),
                   Factory.create(:magazine, published_on: Date.yesterday),
                   Factory.create(:magazine, published_on: Date.yesterday, notification_sent: true)]
      expect(Magazine.published).to eq [magazines.last]
    end
  end

  describe ".with_meetings" do
    let!(:magazine1) { Factory.create(:magazine) }
    let!(:magazine2) { Factory.create(:magazine) }
    let!(:meeting)   { Factory.create(:meeting, magazine: magazine1) }
    it "returns magazines with meetings & not those without" do
      expect(Magazine.with_meetings).to eq [magazine1]
    end
  end

  describe "#accepts_submissions_from" do
    context "when this is the first magazine" do
      it "defaults to today" do
        mag = Magazine.new
        mag2 = Magazine.new :accepts_submissions_from => Time.zone.now.to_date
        mag.accepts_submissions_from.should == mag2.accepts_submissions_from
      end
      it "sets the time part to 00:00:00" do
        mag = Magazine.create accepts_submissions_from: Time.now
        mag.accepts_submissions_from.hour.should == 0
        mag.accepts_submissions_from.min.should == 0
        mag.accepts_submissions_from.sec.should == 0
      end
    end

    context "when there are other magazines" do
      context "in the same publication" do
        it "defaults to latest_mag.accepts_submissions_until + 1" do
          mag = Magazine.create
          mag2 = Magazine.new
          mag2.accepts_submissions_from.to_date.should == (mag.accepts_submissions_until.to_date + 1.day)
        end
        it "cannot fall within another magazine's range" do
          orig = Magazine.create
          mag = Magazine.new accepts_submissions_from: orig.accepts_submissions_from + 1.day
          mag.should_not be_valid
        end
      end
      context "in different publications" do
        before { Magazine.any_instance.unstub(:publication) }
        it "ignores them and uses the default of today" do
          reference = Magazine.new

          in_1st_publication = Magazine.create publication: publications.first
          publications.first.magazines.reload
          in_2nd_publication = Magazine.new publication: publications.last
          in_2nd_publication.accepts_submissions_from.should == reference.accepts_submissions_from
        end
        it "can fall within one of those magazine's ranges just fine" do
          orig = Magazine.create publication: publications.first
          publications.first.magazines.reload
          mag = Magazine.new publication: publications.last, accepts_submissions_from: orig.accepts_submissions_from + 1.day
          mag.should be_valid
        end
      end
      context "in both this and other publications" do
        before { Magazine.any_instance.unstub(:publication) }
        it "only considers its own publication's magazines when calculating the default" do
          samesies  = Magazine.create publication: publications.first
          different = Magazine.create publication: publications.last, accepts_submissions_from: Time.zone.now + 6.months
          publications.first.magazines.reload
          publications.last.magazines.reload
          mag = Magazine.new publication: publications.first
          mag.accepts_submissions_from.to_date.should == (samesies.accepts_submissions_until.to_date + 1.day)
        end
      end
    end
  end

  describe "#accepts_submissions_until" do
    it "defaults to six months after accepts_submissions_from" do
      mag = Magazine.create
      mag.accepts_submissions_until.to_date.should == mag.accepts_submissions_from.to_date + 6.months
      # need to test another one, since the way `from` initializes changes with subsequent mags
      mag2 = Magazine.new
      mag2.accepts_submissions_until.to_date.should == mag2.accepts_submissions_from.to_date + 6.months
    end
    it "sets the time part to 23:59:59" do
      mag = Magazine.create
      mag.accepts_submissions_until.hour.should == 23
      mag.accepts_submissions_until.min.should == 59
      mag.accepts_submissions_until.sec.should == 59
    end

    it "must be > self.accepts_submissions_from" do
      mag = Magazine.new(
        :accepts_submissions_from  => Date.today,
        :accepts_submissions_until => Date.yesterday
      )
      mag.should_not be_valid
    end
    context "when there are other magazines" do
      context "in the same publication" do
        it "cannot fall within one of their ranges" do
          orig = Magazine.create
          mag = Magazine.new(
            accepts_submissions_until: orig.accepts_submissions_until - 1.day,
            accepts_submissions_from: Date.yesterday
          )
          mag.should_not be_valid

          orig.accepts_submissions_until = orig.accepts_submissions_until - 1.day
          expect(orig).to be_valid
        end
      end
      context "in different publications" do
        before { Magazine.any_instance.unstub(:publication) }
        it "can fall within one of those magazine's ranges just fine" do
          orig = Magazine.create publication: publications.first
          publications.first.magazines.reload
          mag = Magazine.new(
            accepts_submissions_until: orig.accepts_submissions_until - 1.day,
            accepts_submissions_from: Date.yesterday,
            publication: publications.last
          )
          expect(mag).to be_valid
        end
      end
    end
  end

  describe "#count_of_scores" do
    it "initializes to 0" do
      m = Magazine.create(count_of_scores: nil)
      m.count_of_scores.should == 0
    end
  end

  describe "#sum_of_scores" do
    it "initializes to 0" do
      m = Magazine.new(sum_of_scores: nil)
      m.sum_of_scores.should == 0
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

  describe "#positions" do
    let(:communicates) { Factory.create :ability, key: "communicates" }
    let(:scores) { Factory.create :ability, key: "scores" }

    it "defaults to those of the previous magazine in the same publication" do
      mag1 = Magazine.create title: "the Bow Nur issue"
      mag1.positions << [
                          Position.create(name: "Admiral", abilities: [communicates]),
                          Position.create(name: "Chef",    abilities: [scores])
                        ]
      mag2 = Magazine.create title: "the salad issue"
      p1 = mag2.positions.first
      p2 = mag2.positions.last

      expect(p1.name).to eq "Admiral"
      expect(p1.abilities).to eq [communicates]
      expect(p2.name).to eq "Chef"
      expect(p2.abilities).to eq [scores]
    end
    it "ignores positions of magazines in other publications" do
      Magazine.any_instance.unstub(:publication)
      mag1 = Magazine.create title: "the Bow Nur issue", publication: publications.first
      mag1.positions << [
                          Position.create(name: "Admiral", abilities: [communicates]),
                          Position.create(name: "Chef",    abilities: [scores])
                        ]
      publications.first.magazines.reload

      mag2 = Magazine.create title: "the salad issue", publication: publications.last
      expect(mag2.positions).to eq([])
    end
  end

  describe "#communicators" do
    let(:magazine) { Factory.create :magazine }
    let(:communicates) { Factory.create :ability, key: 'communicates' }
    let(:scores) { Factory.create :ability, key: 'scores' }
    let(:position) { Factory.create :position, magazine: magazine, abilities: [communicates] }
    let(:position2) { Factory.create :position, magazine: magazine, abilities: [scores] }
    let(:person) { Factory.create :person, positions: [position] }
    let(:person2) { Factory.create :person, positions: [position2] }
    it "returns people in a position with the 'communicates' ability" do
      person2 # instantiate
      expect(magazine.communicators).to eq([person])
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
      meeting  = Meeting.create(:datetime => Date.tomorrow, magazine: mag)
      meeting2 = Meeting.create(:datetime => Date.tomorrow + 6.months, magazine: mag2)
      sub      = Factory.create :submission, magazine: mag
      sub2     = Factory.create :submission, magazine: mag2
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

  def a_magazine_has_just_finished options = {}
    @mag      = Magazine.create(
      :nickname => "Diner",
      :title    => "A Problematic Late-Night Diner",
      :accepts_submissions_until => Date.yesterday,
      :accepts_submissions_from  => 6.months.ago
    )
    @sub      = Factory.create :submission, magazine: @mag
    @sub2     = Factory.create :submission, magazine: @mag
    @meeting  = Meeting.create datetime: Date.yesterday, magazine: @mag
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

  describe "#to_s (and deprecated #present_name)" do
    let(:mag) { Factory.create :magazine }

    it "returns just the magazine title, if it's set" do
      mag.present_name.should == mag.title
      mag.to_s.should == mag.title
    end

    it "returns 'the <nickname> issue' if the title isn't set" do
      mag.update_attributes title: nil
      mag.to_s(:reload).should == "the #{mag.nickname} issue"
      mag.present_name.should  == "the #{mag.nickname} issue"
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
        @mag.published_on.to_date.should == Time.zone.now.to_date
      end

      it "sets checked magazines to published and the rest to rejected" do
        @sub.reload.should be_rejected
        @sub2.reload.should be_published
      end

      it "sets the position of the published submissions" do
        @sub2.reload.position.should_not be_nil
      end

      it "creates 5 pages at minimum: 1 for cover, 1 for Notes, 1 for Staff, 1 for ToC, and 1 per 3 submissions after that" do
        @mag.pages.length.should == 5
      end
    end

    it "when called correctly publishes any previous magazines that were for some reason not published themselves" do
      old_mag = Magazine.create accepts_submissions_from: 1.year.ago, accepts_submissions_until: 6.months.ago, nickname: "old"
      new_mag = Magazine.create accepts_submissions_from: 6.months.ago, accepts_submissions_until: Date.yesterday, nickname: "new"
      new_mag.publish []
      old_mag.reload.published_on.should_not be_nil
    end

    it "when called correctly destroys positions that have the 'disappears' ability on this and older magazines" do
      a1 = Ability.create key: 'disappears', description: 'disappears'
      mag1 = Magazine.create title: "the cat issue", accepts_submissions_from: 3.months.ago, accepts_submissions_until: 2.months.ago
      mag2 = Magazine.create title: "the dog issue",                                         accepts_submissions_until: 1.month.ago
      mag3 = Magazine.create title: "the pig issue",                                         accepts_submissions_until: Date.yesterday
      mag1.positions << [Position.create(name: "Admiral", abilities: [a1])]
      mag2.positions << [Position.create(name: "Admiral", abilities: [a1])]
      mag3.positions << [Position.create(name: "Admiral", abilities: [a1])]
      mag2.publish []
      mag1.positions.reload.should be_empty
      mag2.positions.reload.should be_empty
      mag3.positions.reload.should_not be_empty
    end
  end

  describe "#notify_authors_of_published_magazine" do
    it "emails all of the authors who submitted for this magazine to let them know which (if any) of their submissions made it, and sets notification_sent to true for the magazine" do
      a_magazine_has_just_finished
      mock_mail = mock(:mail)
      mock_mail.stub(:deliver)
      @mag.publish [@sub2]
      [@sub, @sub2].each do |sub|
        Notifications.should_receive(:we_published_a_magazine).with(sub.email, @mag, [sub]).and_return(mock_mail)
      end
      @mag.notify_authors_of_published_magazine
      @mag.notification_sent?.should be_true
    end
    it "uses the :we_published_a_magazine_a_while_ago notification if the magazine was published more than two months ago" do
      a_magazine_has_just_finished
      mock_mail = mock(:mail)
      mock_mail.stub(:deliver)
      @mag.publish [@sub2]
      @mag.update_attributes published_on: 3.months.ago
      [@sub, @sub2].each do |sub|
        Notifications.should_receive(:we_published_a_magazine_a_while_ago).with(sub.email, @mag, [sub]).and_return(mock_mail)
      end
      @mag.notify_authors_of_published_magazine
    end
  end

  describe "#published?" do
    let(:mag) { Factory.create :magazine }

    it "returns false if the magazine has no published_on value" do
      mag.should_not be_published
    end

    it "returns false if the magazine has a published_on value but :notificatin_sent == false" do
      mag.update_attribute :published_on, Date.today
      mag.should_not be_published
    end

    it "returns true if the notification has been sent" do
      mag.update_attributes published_on: Date.today, notification_sent: true
      mag.should be_published
    end
  end

  describe "self.unpublished" do
    it "returns only magazines that have not been published" do
      pub   = Magazine.create(accepts_submissions_from: 1.week.ago, accepts_submissions_until: Date.yesterday).publish []
      unpub = Magazine.create
      Magazine.unpublished.should == [unpub]
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

    it "is scopable" do
      @mag.submissions.respond_to?(:where).should be_true
    end

    it "returns submissions for the specified magazine, not some other magazine" do
      mag2 = Magazine.create(:nickname => "Poopty poopty pants")
      meeting = Meeting.create(:datetime => 1.week.from_now, magazine: mag2)
      sub = Factory.create :submission, magazine: mag2
      meeting.submissions << sub
      mag2.submissions.should == [sub]
      @mag.submissions.should_not include(sub)
    end

    context "when the notification has been sent but the magazine hasn't even been FULLY published" do
      before do
        @mag.stub(:published?).and_return(false)
        @mag.stub(:published_on).and_return(Date.yesterday)
      end
      it "only returns published submissions" do
        @mag.submissions.should be_blank
        @sub.has_been(:published)
        @mag.reload.submissions.should include(@sub)
      end
      it "will return all the submissions if passed :all" do
        @mag.submissions(:all).should_not be_blank
      end
    end
  end

  describe "#viewable_by?(person)" do
    let(:mag) { Magazine.new accepts_submissions_until: Date.yesterday }
    let(:per) { Factory.build :person }
    it "returns false if the magazine has not been published" do
      mag.stub(:published_on).and_return(false)
      mag.should_not be_viewable_by(per)
    end
    it "returns false if the magazine has been published but no notification has been sent and the person does not have the orchestrates ability" do
      mag.stub(:published_on).and_return(true)
      per.stub(:orchestrates?).and_return(false)
      mag.should_not be_viewable_by(per)
    end
    it "returns true if the magazine has been published even if no notification has been sent if the person has the orchestrates ability" do
      mag.stub(:published_on).and_return(true)
      per.stub(:orchestrates?).and_return(true)
      mag.should be_viewable_by(per)
    end
    it "returns true if the mag has been published but no noti sent and the person orchestrates the mag BEFORE this one, if passed :or_adjacent" do
      mag.stub(:published_on).and_return(true)
      mag2 = Magazine.create accepts_submissions_until: 6.months.ago, accepts_submissions_from: 12.months.ago
      mag2.publish([]).update_attribute :notification_sent, true
      pos = mag2.positions.create name: "bum", abilities: [Ability.create(key: 'orchestrates', description: ":-I")]
      per.save; per.positions << pos
      Magazine.stub(:before).and_return(mag2)
      per.stub(:orchestrates).with(mag2) { true }
      mag.should be_viewable_by(per, :or_adjacent)
    end
    it "returns true regardless of the person if the magazine has been published and the notification has been sent" do
      mag.stub(:published_on).and_return(true)
      mag.stub(:notification_sent).and_return(true)
      mag.should be_viewable_by(per)
    end
  end

  describe ".before" do
    let(:magazines) { [Magazine.create(publication_id: publications.first.id),
                       Magazine.create(publication_id: publications.first.id),
                       Magazine.create(publication_id: publications.first.id),
                       Magazine.create(publication_id: publications.last.id),
                       Magazine.create(publication_id: publications.last.id),
                       Magazine.create(publication_id: publications.last.id)] }
    it "returns the magazine that was published before the one provided, in the same publication" do
      Magazine.any_instance.unstub(:publication)
      Magazine.before(magazines[5]).should == magazines[4]
      Magazine.before(magazines[4]).should == magazines[3]
      Magazine.before(magazines[3]).should == nil
      Magazine.before(magazines[2]).should == magazines[1]
      Magazine.before(magazines[1]).should == magazines[0]
      Magazine.before(magazines[0]).should == nil
    end
  end
  describe ".after" do
    let(:magazines) { [Magazine.create(publication_id: publications.first.id),
                       Magazine.create(publication_id: publications.first.id),
                       Magazine.create(publication_id: publications.first.id),
                       Magazine.create(publication_id: publications.last.id),
                       Magazine.create(publication_id: publications.last.id),
                       Magazine.create(publication_id: publications.last.id)] }
    it "returns the magazine that was published after the one provided, in the same publication" do
      Magazine.any_instance.unstub(:publication)
      Magazine.after(magazines[0]).should == magazines[1]
      Magazine.after(magazines[1]).should == magazines[2]
      Magazine.after(magazines[2]).should == nil
      Magazine.after(magazines[3]).should == magazines[4]
      Magazine.after(magazines[4]).should == magazines[5]
      Magazine.after(magazines[5]).should == nil
    end
  end

  describe "#older_unpublished_magazines" do
    before { Magazine.any_instance.unstub(:publication) }
    it "scopes by the current publication" do
      older_mags = [Factory.create(:magazine, publication: publications.first, accepts_submissions_from: Time.zone.now - 18.months),
                    Factory.create(:magazine, publication: publications.last, accepts_submissions_from: Time.zone.now - 18.months) ]
      mag = Magazine.create publication_id: publications.first.id
      publications.first.magazines.reload
      publications.last.magazines.reload
      expect(mag.older_unpublished_magazines).to eq [older_mags.first]
    end
  end

  describe "#timeframe_freshly_over?" do
    let(:magazine) { stub_model(Magazine, published_on: nil) }

    context "when published_on is nil" do
      context "when #accepts_submissions_until is in the past" do
        it "returns true" do
          magazine.stub(:accepts_submissions_until).and_return(Time.zone.now - 1.minute)
          expect(magazine.timeframe_freshly_over?).to be_true
        end
      end
      context "when #accepts_submissions_until is in the future" do
        it "returns false" do
          magazine.stub(:accepts_submissions_until).and_return(Time.zone.now + 1.minute)
          expect(magazine.timeframe_freshly_over?).to be_false
        end
      end
    end

    context "when published_on is present" do
      it "returns false, even when #accepts_submissions_from is in the past" do
        magazine.stub(:published_on).and_return(Time.zone.now)
        magazine.stub(:accepts_submissions_until).and_return(Time.zone.now - 1.minute)
        expect(magazine.timeframe_freshly_over?).to be_false
      end
    end
  end

end
