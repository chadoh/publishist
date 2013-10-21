class Magazine < ActiveRecord::Base
  extend Memoist

  belongs_to :publication, inverse_of: :magazines
  has_many :meetings,  dependent: :nullify, include: :submissions
  has_many :pages,     dependent: :destroy, order:   :position
  has_many :positions, dependent: :destroy
  has_many :roles,     through:   :positions, dependent: :destroy
  has_many :people,    through:   :roles
  has_many :abilities, through:   :positions, dependent: :destroy
  has_many :subs,      dependent: :nullify, class_name: 'Submission'
  extend FriendlyId
  friendly_id :to_s, :use => [:slugged, :history]
  has_attached_file :pdf,
    :storage        => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path           => "/magazines/:filename"
  has_attached_file :cover_art,
    :storage        => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path           => "/cover_art/:style/:filename",
    :styles         => { thumb: "330x330>" }

  validates_presence_of :nickname
  validates_presence_of :accepts_submissions_from
  validates_presence_of :accepts_submissions_until
  validate :from_happens_before_until
  validate :magazine_ranges_dont_conflict
  validates_attachment_content_type :pdf,
    :content_type => [ 'application/pdf' ],
    :if           => Proc.new { |submission| submission.pdf.file? },
    :message      => "has to be a valid pdf"
  validates_attachment_content_type :cover_art,
    :content_type => [ 'image/png', 'image/jpeg', 'image/gif', 'image/svg+xml', 'image/tiff', 'image/vnd.microsoft.icon' ],
    :if           => Proc.new { |magazine| magazine.cover_art.file? },
    :message      => "must be an image"

  after_initialize "self.nickname = 'next' if self.nickname.blank?"
  after_initialize :accepts_from_after_latest_or_perhaps_today
  after_initialize :accepts_until_six_months_later
  after_initialize :score_counters_cannot_be_nil
  after_create     :same_positions_as_previous_mag

  default_scope order("accepts_submissions_until DESC")
  scope :unpublished, where(published_on: nil)
  scope :published, where("published_on IS NOT NULL AND notification_sent = true")

  def submissions(flags = nil)
    if !self.published_on.present? || flags == :all
      self.subs
    else
      self.subs.published
    end
  end

  def average_score
    if count_of_scores == 0 then nil else
      (sum_of_scores.to_f / count_of_scores * 100).round.to_f / 100
    end
  end

  def highest_scores how_many = 50
    self.submissions.where(state: Submission.state(:scored)) \
      .sort {|a,b| b.average_score <=> a.average_score } \
      .shift(how_many)
  end

  def all_scores_above this_score
    self.submissions.where(state: Submission.state(:scored)) \
      .reject {|s| s.average_score < this_score } \
      .sort {|a,b| b.average_score <=> a.average_score }
  end

  def present_name
    self.to_s
  end

  def to_s
    title.presence || "the #{nickname} issue"
  end

  class MagazineStillAcceptingSubmissionsError < StandardError; end

  def publish array_of_winners
    if self.accepts_submissions_until <= Time.now
      all_submissions = self.submissions
      published = array_of_winners
      rejected = all_submissions - published

      self.update_attribute :published_on, Time.zone.now


      self.pages = [
        Page.create(:title => 'Cover'),
        Page.create(:title => 'Notes'),
        staff = Page.create(:title => 'Staff'),
        toc   = Page.create(:title => 'ToC'),
      ]
      toc.table_of_contents = TableOfContents.create
      staff.staff_list = StaffList.create

      rejected.each  {|sub| sub.has_been(:rejected)  }
      published.each_slice(3) do |three_submissions|
        page = self.pages.create
        three_submissions.each do |sub|
          sub.update_attributes page: page, state: :published
        end
      end
      self.pages.each do |page|
        page.submissions.each_with_index do |sub, i|
          sub.update_attribute :position, i + 1
        end
      end
      older_unpublished_magazines.each {|m| m.publish [] }

      # get rid of ALL positions marked with 'disappears' (even if they somehow ended up on older mags)
      self.positions.joins(:abilities).where(abilities: { key: 'disappears' }).each do |position|
        position.destroy
      end
      self
    else
      raise MagazineStillAcceptingSubmissionsError, "You cannot publish a magazine that is still accepting submissions"
    end
  end

  def communicators
    people.joins(:abilities).where(abilities: { key: 'communicates' })
  end

  def notification_sent?
    !!self.notification_sent
  end

  def notify_authors_of_published_magazine
    self.submissions(:all).group_by(&:email).each do |author_email, her_submissions|
      if self.published_on >= 2.months.ago
        Notifications.delay.we_published_a_magazine(author_email, self, her_submissions)
      else
        Notifications.delay.we_published_a_magazine_a_while_ago(author_email, self, her_submissions)
      end
    end
    self.update_attributes notification_sent: true
  end

  def page page_title
    page_title = page_title.to_s
    if page_title.present?
      self.pages.find_by_title(page_title).presence || \
      self.pages.find_by_position(page_title.to_i + 4).presence
    else
      self.pages.first
    end
  end

  def create_page_at position
    page = self.pages.create
    page.insert_at position.to_i if position.present?
    page
  end

  class << self
    def before mag
      # ordered by "accepts_submissions_untl DESC", which means most recent first
      mag.publication.magazines.where("accepts_submissions_until <= ?", mag.accepts_submissions_from).first
    end

    def after mag
      # ordered by "accepts_submissions_untl DESC", which means most recent first
      mag.publication.magazines.where("accepts_submissions_from >= ?", mag.accepts_submissions_until).last
    end
  end

  def published?
    published_on.present? && notification_sent?
  end

  def viewable_by? person, *args
    self.published? || (self.published_on.present? && person.try(:orchestrates?, self, *args))
  end

  def older_unpublished_magazines
    publication.magazines.unpublished.where("accepts_submissions_from < ?", self.accepts_submissions_from)
  end

  memoize :average_score, :to_s

protected

  def accepts_from_after_latest_or_perhaps_today
    if self.accepts_submissions_from.blank?
      if publication && publication.magazines.present?
        self.accepts_submissions_from = publication.magazines.first.accepts_submissions_until + 1
      else
        self.accepts_submissions_from = Time.zone.now.to_date
      end
    end
    self.accepts_submissions_from = self.accepts_submissions_from.beginning_of_day
  end

  def accepts_until_six_months_later
    self.accepts_submissions_until = self.accepts_submissions_from + 6.months if self.accepts_submissions_until.blank?
    self.accepts_submissions_until = self.accepts_submissions_until.end_of_day
  end

  def from_happens_before_until
    if !!self.accepts_submissions_until && !!self.accepts_submissions_from
      if self.accepts_submissions_until <= self.accepts_submissions_from
        errors.add(:accepts_submissions_until, "must come after \"Accepts submissions from\"")
      end
    end
  end

  def magazine_ranges_dont_conflict
    mags = publication.magazines.where(
      'accepts_submissions_from  < :from AND ' + \
      'accepts_submissions_until > :from',
      from: self.accepts_submissions_from
    )
    if mags.present? && (mags.length > 1 || mags.first != self)
      errors.add :accepts_submissions_from,  "can't occurr during another magazine (#{mags.first} accepts submissions until #{mags.first.accepts_submissions_until})"
    end
    mags = publication.magazines.where(
      'accepts_submissions_from  < ? AND ' + \
      'accepts_submissions_until > ?',
      self.accepts_submissions_until,
      self.accepts_submissions_until
    )
    if mags.present? && (mags.length > 1 || mags.first != self)
      then errors.add :accepts_submissions_until, "can't occurr during another magazine (#{mags.first} accepts submissions from #{mags.first.accepts_submissions_from})"
    end
  end

  def score_counters_cannot_be_nil
    if new_record?
      self.sum_of_scores   = 0
      self.count_of_scores = 0
    end
  end

  def same_positions_as_previous_mag
    previous_mag = publication.magazines.where("accepts_submissions_from < ?", self.accepts_submissions_from).first
    if previous_mag
      for position in previous_mag.positions
        self.positions << Position.create(name: position.name, abilities: position.abilities)
      end
    end
  end
end
