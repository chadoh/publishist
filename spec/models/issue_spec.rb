require 'spec_helper'

describe Issue do
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
    it "returns only issues that've been published and that have had their notification sent" do
      issues = [Factory.create(:issue),
                   Factory.create(:issue, published_on: Date.yesterday),
                   Factory.create(:issue, published_on: Date.yesterday, notification_sent: true)]
      expect(Issue.published).to eq [issues.last]
    end
  end

  describe ".with_meetings" do
    let!(:issue1) { Factory.create(:issue) }
    let!(:issue2) { Factory.create(:issue) }
    let!(:meeting)   { Factory.create(:meeting, issue: issue1) }
    it "returns issues with meetings & not those without" do
      expect(Issue.with_meetings).to eq [issue1]
    end
  end

  describe "#accepts_submissions_from" do
    context "when this is the first issue" do
      it "defaults to today" do
        issue = Issue.new
        mag2 = Issue.new :accepts_submissions_from => Time.zone.now.to_date
        issue.accepts_submissions_from.should == mag2.accepts_submissions_from
      end
      it "sets the time part to 00:00:00" do
        issue = Issue.create accepts_submissions_from: Time.now
        issue.accepts_submissions_from.hour.should == 0
        issue.accepts_submissions_from.min.should == 0
        issue.accepts_submissions_from.sec.should == 0
      end
    end

    context "when there are other issues" do
      context "in the same publication" do
        it "defaults to latest_issue.accepts_submissions_until + 1" do
          issue = Issue.create
          mag2 = Issue.new
          mag2.accepts_submissions_from.to_date.should == (issue.accepts_submissions_until.to_date + 1.day)
        end
        it "cannot fall within another issue's range" do
          orig = Issue.create
          issue = Issue.new accepts_submissions_from: orig.accepts_submissions_from + 1.day
          issue.should_not be_valid
        end
      end
      context "in different publications" do
        before { Issue.any_instance.unstub(:publication) }
        it "ignores them and uses the default of today" do
          reference = Issue.new

          in_1st_publication = Issue.create publication: publications.first
          publications.first.issues.reload
          in_2nd_publication = Issue.new publication: publications.last
          in_2nd_publication.accepts_submissions_from.should == reference.accepts_submissions_from
        end
        it "can fall within one of those issue's ranges just fine" do
          orig = Issue.create publication: publications.first
          publications.first.issues.reload
          issue = Issue.new publication: publications.last, accepts_submissions_from: orig.accepts_submissions_from + 1.day
          issue.should be_valid
        end
      end
      context "in both this and other publications" do
        before { Issue.any_instance.unstub(:publication) }
        it "only considers its own publication's issues when calculating the default" do
          samesies  = Issue.create publication: publications.first
          different = Issue.create publication: publications.last, accepts_submissions_from: Time.zone.now + 6.months
          publications.first.issues.reload
          publications.last.issues.reload
          issue = Issue.new publication: publications.first
          issue.accepts_submissions_from.to_date.should == (samesies.accepts_submissions_until.to_date + 1.day)
        end
      end
    end
  end

  describe "#accepts_submissions_until" do
    it "defaults to six months after accepts_submissions_from" do
      issue = Issue.create
      issue.accepts_submissions_until.to_date.should == issue.accepts_submissions_from.to_date + 6.months
      # need to test another one, since the way `from` initializes changes with subsequent mags
      mag2 = Issue.new
      mag2.accepts_submissions_until.to_date.should == mag2.accepts_submissions_from.to_date + 6.months
    end
    it "sets the time part to 23:59:59" do
      issue = Issue.create
      issue.accepts_submissions_until.hour.should == 23
      issue.accepts_submissions_until.min.should == 59
      issue.accepts_submissions_until.sec.should == 59
    end

    it "must be > self.accepts_submissions_from" do
      issue = Issue.new(
        :accepts_submissions_from  => Date.today,
        :accepts_submissions_until => Date.yesterday
      )
      issue.should_not be_valid
    end
    context "when there are other issues" do
      context "in the same publication" do
        it "cannot fall within one of their ranges" do
          orig = Issue.create
          issue = Issue.new(
            accepts_submissions_until: orig.accepts_submissions_until - 1.day,
            accepts_submissions_from: Date.yesterday
          )
          issue.should_not be_valid

          orig.accepts_submissions_until = orig.accepts_submissions_until - 1.day
          expect(orig).to be_valid
        end
      end
      context "in different publications" do
        before { Issue.any_instance.unstub(:publication) }
        it "can fall within one of those issue's ranges just fine" do
          orig = Issue.create publication: publications.first
          publications.first.issues.reload
          issue = Issue.new(
            accepts_submissions_until: orig.accepts_submissions_until - 1.day,
            accepts_submissions_from: Date.yesterday,
            publication: publications.last
          )
          expect(issue).to be_valid
        end
      end
    end
  end

  describe "#count_of_scores" do
    it "initializes to 0" do
      m = Issue.create(count_of_scores: nil)
      m.count_of_scores.should == 0
    end
  end

  describe "#sum_of_scores" do
    it "initializes to 0" do
      m = Issue.new(sum_of_scores: nil)
      m.sum_of_scores.should == 0
    end
  end

  describe "#nickname" do
    it "defaults to 'next'" do
      issue = Issue.new
      issue.nickname.should == "next"
    end
  end

  describe "#notification_sent" do
    it "defaults to 'false'" do
      issue = Issue.new
      issue.notification_sent?.should be_false
    end
  end

  describe "#positions" do
    let(:communicates) { Factory.create :ability, key: "communicates" }
    let(:scores) { Factory.create :ability, key: "scores" }

    it "defaults to those of the previous issue in the same publication" do
      mag1 = Issue.create title: "the Bow Nur issue"
      mag1.positions << [
                          Position.create(name: "Admiral", abilities: [communicates]),
                          Position.create(name: "Chef",    abilities: [scores])
                        ]
      mag2 = Issue.create title: "the salad issue"
      p1 = mag2.positions.first
      p2 = mag2.positions.last

      expect(p1.name).to eq "Admiral"
      expect(p1.abilities).to eq [communicates]
      expect(p2.name).to eq "Chef"
      expect(p2.abilities).to eq [scores]
    end
    it "ignores positions of issues in other publications" do
      Issue.any_instance.unstub(:publication)
      mag1 = Issue.create title: "the Bow Nur issue", publication: publications.first
      mag1.positions << [
                          Position.create(name: "Admiral", abilities: [communicates]),
                          Position.create(name: "Chef",    abilities: [scores])
                        ]
      publications.first.issues.reload

      mag2 = Issue.create title: "the salad issue", publication: publications.last
      expect(mag2.positions).to eq([])
    end
  end

  describe "#communicators" do
    let(:issue) { Factory.create :issue }
    let(:communicates) { Factory.create :ability, key: 'communicates' }
    let(:scores) { Factory.create :ability, key: 'scores' }
    let(:position) { Factory.create :position, issue: issue, abilities: [communicates] }
    let(:position2) { Factory.create :position, issue: issue, abilities: [scores] }
    let(:person) { Factory.create :person, positions: [position] }
    let(:person2) { Factory.create :person, positions: [position2] }
    it "returns people in a position with the 'communicates' ability" do
      person2 # instantiate
      expect(issue.communicators).to eq([person])
    end
  end

  describe "with the default settings" do
    it "should be valid" do
      Issue.new.should be_valid
    end
  end

  describe "#average_score" do
    it "returns the average score for the submissions in this issue" do
      issue      = Factory.create :issue
      mag2     = Factory.create :issue
      meeting  = Meeting.create(:datetime => Date.tomorrow, issue: issue)
      meeting2 = Meeting.create(:datetime => Date.tomorrow + 6.months, issue: mag2)
      sub      = Factory.create :submission, issue: issue
      sub2     = Factory.create :submission, issue: mag2
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
      issue.reload.average_score.should == 4.5
    end
  end

  def an_issue_has_just_finished options = {}
    @issue      = Issue.create(
      :nickname => "Diner",
      :title    => "A Problematic Late-Night Diner",
      :accepts_submissions_until => Date.yesterday,
      :accepts_submissions_from  => 6.months.ago
    )
    @sub      = Factory.create :submission, issue: @issue
    @sub2     = Factory.create :submission, issue: @issue
    @meeting  = Meeting.create datetime: Date.yesterday, issue: @issue
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
    it "returns the highest-scoring submissions for the issue" do
      an_issue_has_just_finished include_scores: true
      @issue.highest_scores(1).should == [@sub2]
    end

    it "does not barf when a submission's scores are nil" do
      an_issue_has_just_finished
      Score.delete_all; Submission.update_all :state => Submission.state(:reviewed)
      @issue.reload.highest_scores.should be_empty
    end
  end

  describe "#all_scores_above(this_score)" do
    it "returns all submissions scored above the given score" do
      an_issue_has_just_finished include_scores: true
      @issue.all_scores_above(6).should == [@sub2]
    end
  end

  describe "#to_s (and deprecated #present_name)" do
    let(:issue) { Factory.create :issue }

    it "returns just the issue title, if it's set" do
      issue.present_name.should == issue.title
      issue.to_s.should == issue.title
    end

    it "returns 'the <nickname> issue' if the title isn't set" do
      issue.update_attributes title: nil
      issue.to_s(:reload).should == "the #{issue.nickname} issue"
      issue.present_name.should  == "the #{issue.nickname} issue"
    end
  end

  describe "#publish(array_of_winners)" do
    it "returns an error if the issue's end-date for submissions has not yet passed" do
      issue = Factory.create :issue
      expect { issue.publish [] }.to raise_error
    end

    context "when called correctly" do
      before do
        an_issue_has_just_finished
        @issue.publish [@sub2]
      end

      it "sets the published_on date for the issue to the current date" do
        @issue.published_on.to_date.should == Time.zone.now.to_date
      end

      it "sets checked issues to published and the rest to rejected" do
        @sub.reload.should be_rejected
        @sub2.reload.should be_published
      end

      it "sets the position of the published submissions" do
        @sub2.reload.position.should_not be_nil
      end

      it "creates 5 pages at minimum: 1 for cover, 1 for Notes, 1 for Staff, 1 for ToC, and 1 per 3 submissions after that" do
        @issue.pages.length.should == 5
      end
    end

    it "when called correctly publishes any previous issues that were for some reason not published themselves" do
      old_issue = Issue.create accepts_submissions_from: 1.year.ago, accepts_submissions_until: 6.months.ago, nickname: "old"
      new_issue = Issue.create accepts_submissions_from: 6.months.ago, accepts_submissions_until: Date.yesterday, nickname: "new"
      new_issue.publish []
      old_issue.reload.published_on.should_not be_nil
    end

    it "when called correctly destroys positions that have the 'disappears' ability on this and older issues" do
      a1 = Ability.create key: 'disappears', description: 'disappears'
      mag1 = Issue.create title: "the cat issue", accepts_submissions_from: 3.months.ago, accepts_submissions_until: 2.months.ago
      mag2 = Issue.create title: "the dog issue",                                         accepts_submissions_until: 1.month.ago
      mag3 = Issue.create title: "the pig issue",                                         accepts_submissions_until: Date.yesterday
      mag1.positions << [Position.create(name: "Admiral", abilities: [a1])]
      mag2.positions << [Position.create(name: "Admiral", abilities: [a1])]
      mag3.positions << [Position.create(name: "Admiral", abilities: [a1])]
      mag2.publish []
      mag1.positions.reload.should be_empty
      mag2.positions.reload.should be_empty
      mag3.positions.reload.should_not be_empty
    end
  end

  describe "#notify_authors_of_published_issue" do
    it "emails all of the authors who submitted for this issue to let them know which (if any) of their submissions made it, and sets notification_sent to true for the issue" do
      an_issue_has_just_finished
      mock_mail = mock(:mail)
      mock_mail.stub(:deliver)
      @issue.publish [@sub2]
      [@sub, @sub2].each do |sub|
        Notifications.should_receive(:we_published_an_issue).with(sub.email, @issue, [sub]).and_return(mock_mail)
      end
      @issue.notify_authors_of_published_issue
      @issue.notification_sent?.should be_true
    end
    it "uses the :we_published_an_issue_a_while_ago notification if the issue was published more than two months ago" do
      an_issue_has_just_finished
      mock_mail = mock(:mail)
      mock_mail.stub(:deliver)
      @issue.publish [@sub2]
      @issue.update_attributes published_on: 3.months.ago
      [@sub, @sub2].each do |sub|
        Notifications.should_receive(:we_published_an_issue_a_while_ago).with(sub.email, @issue, [sub]).and_return(mock_mail)
      end
      @issue.notify_authors_of_published_issue
    end
  end

  describe "#published?" do
    let(:issue) { Factory.create :issue }

    it "returns false if the issue has no published_on value" do
      issue.should_not be_published
    end

    it "returns false if the issue has a published_on value but :notificatin_sent == false" do
      issue.update_attribute :published_on, Date.today
      issue.should_not be_published
    end

    it "returns true if the notification has been sent" do
      issue.update_attributes published_on: Date.today, notification_sent: true
      issue.should be_published
    end
  end

  describe "self.unpublished" do
    it "returns only issues that have not been published" do
      pub   = Issue.create(accepts_submissions_from: 1.week.ago, accepts_submissions_until: Date.yesterday).publish []
      unpub = Issue.create
      Issue.unpublished.should == [unpub]
    end
  end

  describe "a published issue" do
    before do
      an_issue_has_just_finished
      @issue.publish [@sub2]
    end

    describe "#page" do
      it "queries a issue's pages by the pages' titles (or pseudo titles)" do
        @issue.page('Cover').position.should == 1
        page = @issue.page('1').submissions.should == [@sub2]
      end

      it "if the provided page is nil, it provides the first page" do
        @issue.page(nil).position.should == 1
      end
    end

    describe "#create_page_at" do
      it "creates a page and inserts it at the supplied position, returning the page" do
        page = @issue.create_page_at(3)
        page.position.should == 3
      end

      it "creates a page but doesn't insert it anywhere if the supplied value is blank" do
        page = @issue.create_page_at("")
        page[:title].should be_blank
      end
    end
  end

  describe "#submissions" do
    before do
      an_issue_has_just_finished
    end

    it "is scopable" do
      @issue.submissions.respond_to?(:where).should be_true
    end

    it "returns submissions for the specified issue, not some other issue" do
      mag2 = Issue.create(:nickname => "Poopty poopty pants")
      meeting = Meeting.create(:datetime => 1.week.from_now, issue: mag2)
      sub = Factory.create :submission, issue: mag2
      meeting.submissions << sub
      mag2.submissions.should == [sub]
      @issue.submissions.should_not include(sub)
    end

    context "when the notification has been sent but the issue hasn't even been FULLY published" do
      before do
        @issue.stub(:published?).and_return(false)
        @issue.stub(:published_on).and_return(Date.yesterday)
      end
      it "only returns published submissions" do
        @issue.submissions.should be_blank
        @sub.has_been(:published)
        @issue.reload.submissions.should include(@sub)
      end
      it "will return all the submissions if passed :all" do
        @issue.submissions(:all).should_not be_blank
      end
    end
  end

  describe "#viewable_by?(person)" do
    let(:issue) { Issue.new accepts_submissions_until: Date.yesterday }
    let(:per) { Factory.build :person }
    it "returns false if the issue has not been published" do
      issue.stub(:published_on).and_return(false)
      issue.should_not be_viewable_by(per)
    end
    it "returns false if the issue has been published but no notification has been sent and the person does not have the orchestrates ability" do
      issue.stub(:published_on).and_return(true)
      per.stub(:orchestrates?).and_return(false)
      issue.should_not be_viewable_by(per)
    end
    it "returns true if the issue has been published even if no notification has been sent if the person has the orchestrates ability" do
      issue.stub(:published_on).and_return(true)
      per.stub(:orchestrates?).and_return(true)
      issue.should be_viewable_by(per)
    end
    it "returns true if the issue has been published but no noti sent and the person orchestrates the issue BEFORE this one, if passed :or_adjacent" do
      issue.stub(:published_on).and_return(true)
      mag2 = Issue.create accepts_submissions_until: 6.months.ago, accepts_submissions_from: 12.months.ago
      mag2.publish([]).update_attribute :notification_sent, true
      pos = mag2.positions.create name: "bum", abilities: [Ability.create(key: 'orchestrates', description: ":-I")]
      per.save; per.positions << pos
      Issue.stub(:before).and_return(mag2)
      per.stub(:orchestrates).with(mag2) { true }
      issue.should be_viewable_by(per, :or_adjacent)
    end
    it "returns true regardless of the person if the issue has been published and the notification has been sent" do
      issue.stub(:published_on).and_return(true)
      issue.stub(:notification_sent).and_return(true)
      issue.should be_viewable_by(per)
    end
  end

  describe ".before" do
    let(:issues) { [Issue.create(publication_id: publications.first.id),
                       Issue.create(publication_id: publications.first.id),
                       Issue.create(publication_id: publications.first.id),
                       Issue.create(publication_id: publications.last.id),
                       Issue.create(publication_id: publications.last.id),
                       Issue.create(publication_id: publications.last.id)] }
    it "returns the issue that was published before the one provided, in the same publication" do
      Issue.any_instance.unstub(:publication)
      Issue.before(issues[5]).should == issues[4]
      Issue.before(issues[4]).should == issues[3]
      Issue.before(issues[3]).should == nil
      Issue.before(issues[2]).should == issues[1]
      Issue.before(issues[1]).should == issues[0]
      Issue.before(issues[0]).should == nil
    end
  end
  describe ".after" do
    let(:issues) { [Issue.create(publication_id: publications.first.id),
                       Issue.create(publication_id: publications.first.id),
                       Issue.create(publication_id: publications.first.id),
                       Issue.create(publication_id: publications.last.id),
                       Issue.create(publication_id: publications.last.id),
                       Issue.create(publication_id: publications.last.id)] }
    it "returns the issue that was published after the one provided, in the same publication" do
      Issue.any_instance.unstub(:publication)
      Issue.after(issues[0]).should == issues[1]
      Issue.after(issues[1]).should == issues[2]
      Issue.after(issues[2]).should == nil
      Issue.after(issues[3]).should == issues[4]
      Issue.after(issues[4]).should == issues[5]
      Issue.after(issues[5]).should == nil
    end
  end

  describe "#older_unpublished_issues" do
    before { Issue.any_instance.unstub(:publication) }
    it "scopes by the current publication" do
      older_mags = [Factory.create(:issue, publication: publications.first, accepts_submissions_from: Time.zone.now - 18.months),
                    Factory.create(:issue, publication: publications.last, accepts_submissions_from: Time.zone.now - 18.months) ]
      issue = Issue.create publication_id: publications.first.id
      publications.first.issues.reload
      publications.last.issues.reload
      expect(issue.older_unpublished_issues).to eq [older_mags.first]
    end
  end

  describe "#timeframe_freshly_over?" do
    let(:issue) { stub_model(Issue, published_on: nil) }

    context "when published_on is nil" do
      context "when #accepts_submissions_until is in the past" do
        it "returns true" do
          issue.stub(:accepts_submissions_until).and_return(Time.zone.now - 1.minute)
          expect(issue.timeframe_freshly_over?).to be_true
        end
      end
      context "when #accepts_submissions_until is in the future" do
        it "returns false" do
          issue.stub(:accepts_submissions_until).and_return(Time.zone.now + 1.minute)
          expect(issue.timeframe_freshly_over?).to be_false
        end
      end
    end

    context "when published_on is present" do
      it "returns false, even when #accepts_submissions_from is in the past" do
        issue.stub(:published_on).and_return(Time.zone.now)
        issue.stub(:accepts_submissions_until).and_return(Time.zone.now - 1.minute)
        expect(issue.timeframe_freshly_over?).to be_false
      end
    end
  end

end
