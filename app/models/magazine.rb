# == Schema Information
# Schema version: 20110904221228
#
# Table name: magazines
#
#  id                        :integer         not null, primary key
#  title                     :string(255)
#  nickname                  :string(255)
#  accepts_submissions_from  :datetime
#  accepts_submissions_until :datetime
#  published_on              :datetime
#  created_at                :datetime
#  updated_at                :datetime
#  count_of_scores           :integer         default(0)
#  sum_of_scores             :integer         default(0)
#  cached_slug               :string(255)
#  notification_sent         :boolean
#  pdf_file_name             :string(255)
#  pdf_content_type          :string(255)
#  pdf_file_size             :integer
#  pdf_updated_at            :datetime
#  cover_art_file_name       :string(255)
#  cover_art_content_type    :string(255)
#  cover_art_file_size       :integer
#  cover_art_updated_at      :datetime
#

class Magazine < ActiveRecord::Base
  extend Memoist

  has_many :meetings,  dependent: :nullify, include: :submissions
  has_many :pages,     dependent: :destroy, order:   :position
  has_many :positions, dependent: :destroy
  has_many :roles,     through:   :positions, dependent: :destroy
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
    :styles         => { thumb: "300x300>" }

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

      self.update_attribute :published_on, Date.today


      self.pages = [
        Page.create(:title => 'Cover'),
        Page.create(:title => 'Notes'),
        staff = Page.create(:title => 'Staff'),
        toc   = Page.create(:title => 'ToC'),
      ]
      toc.table_of_contents = TableOfContents.create
      staff.staff_list = StaffList.create

      # published.each {|sub| sub.has_been(:published) }
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
      older_unpublished_magazines = Magazine.unpublished.where("accepts_submissions_from < ?", self.accepts_submissions_from)
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
    def current
      self.where('accepts_submissions_from  < ? AND ' + \
        'accepts_submissions_until > ?',
        Date.today.end_of_day, Date.today.beginning_of_day).first || self.first
    end

    def current!
      mag = self.where('accepts_submissions_from  < ? AND ' + \
              'accepts_submissions_until > ?',
              Date.today.end_of_day, Date.today.beginning_of_day).first
      if !mag && self.count != 0
        mag = self.create
      end
      mag
    end

    def before mag
      all.select{|m| m.accepts_submissions_until <= mag.accepts_submissions_from }.sort_by(&:accepts_submissions_until).reverse.first
    end

    def after mag
      all.select{|m| m.accepts_submissions_from >= mag.accepts_submissions_until }.sort_by(&:accepts_submissions_from).first
    end
  end

  def published?
    published_on.present? && notification_sent?
  end

  def viewable_by? person, *args
    self.published? || (self.published_on.present? && person.try(:orchestrates?, self, *args))
  end

  memoize :average_score, :to_s

protected

  def accepts_from_after_latest_or_perhaps_today
    if self.accepts_submissions_from.blank?
      if Magazine.all.present?
        self.accepts_submissions_from = Magazine.unscoped.order("accepts_submissions_until DESC").first.accepts_submissions_until + 1
      else
        self.accepts_submissions_from = Date.today
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
    mags = Magazine.where(
      'accepts_submissions_from  < ? AND ' + \
      'accepts_submissions_until > ?',
      self.accepts_submissions_from,
      self.accepts_submissions_from
    )
    if mags.present? && (mags.length > 1 || mags.first != self)
      then errors.add :accepts_submissions_from,  "can't occurr during another magazine (#{mags.first} accepts submissions until #{mags.first.accepts_submissions_until})"
    end
    mags = Magazine.where(
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
    previous_mag = Magazine.where("accepts_submissions_from < ?", self.accepts_submissions_from).first
    if previous_mag
      for position in previous_mag.positions
        self.positions << Position.create(name: position.name, abilities: position.abilities)
      end
    end
  end
end
