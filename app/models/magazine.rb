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
  extend ActiveSupport::Memoizable

  validates_presence_of :nickname
  validates_presence_of :accepts_submissions_from
  validates_presence_of :accepts_submissions_until
  validate :from_happens_before_until
  validate :magazine_ranges_dont_conflict

  validates_attachment_content_type :pdf,
    :content_type => [ 'application/pdf' ],
    :if           => Proc.new { |submission| submission.pdf.file? },
    :message      => "has to be a valid pdf"

  has_attached_file :pdf,
    :storage        => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path           => "/magazines/:filename"

  validates_attachment_content_type :cover_art,
    :content_type => [ 'image/png', 'image/jpeg', 'image/gif', 'image/svg+xml', 'image/tiff', 'image/vnd.microsoft.icon' ],
    :if           => Proc.new { |magazine| magazine.cover_art.file? },
    :message      => "must be an image"

  has_attached_file :cover_art,
    :storage        => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path           => "/cover_art/:style/:filename",
    :styles         => { thumb: "300x300>" }

  after_initialize "self.nickname = 'next' if self.nickname.blank?"
  after_initialize :accepts_from_after_latest_or_perhaps_today
  after_initialize :accepts_until_six_months_later

  default_scope order("accepts_submissions_until DESC")

  has_many :meetings,   dependent: :nullify, include: :submissions
  has_many :pages,      dependent: :destroy, order:   :position
  has_many :positions,  dependent: :destroy
  has_many :roles,      through:   :positions

  has_friendly_id :nickname, :use_slug => true

  # TODO: This should be a nested hm:t; waiting for Rails 3.1 which will allow this
  def submissions options = {}
    options = options.is_a?(Hash) ? options : { options => true }

    submission_ids = self.meetings.collect(&:packlets).flatten.collect(&:submission_id).uniq
    if self.published? && options[:all] != true
      Submission.where :id + submission_ids, :state => Submission.state(:published)
    else
      Submission.where :id + submission_ids
    end
  end

  def average_score
    if count_of_scores == 0 then nil else
      (sum_of_scores.to_f / count_of_scores * 100).round.to_f / 100
    end
  end

  def highest_scores how_many = 50
    self.submissions.where(:state >> Submission.state(:scored)) \
      .sort {|a,b| b.average_score <=> a.average_score } \
      .shift(how_many)
  end

  def all_scores_above this_score
    self.submissions.where(:state >> Submission.state(:scored)) \
      .reject {|s| s.average_score < this_score } \
      .sort {|a,b| b.average_score <=> a.average_score }
  end

  def present_name
    self.to_s
  end

  def to_s
    title.presence || "the #{nickname} magazine"
  end

  def publish array_of_winners
    if self.accepts_submissions_until <= Time.now
      all_submissions = self.submissions
      published = array_of_winners
      rejected = all_submissions - published

      self.update_attributes :published_on => Date.today
      for sub in published do sub.has_been(:published) end
      for sub in rejected  do sub.has_been(:rejected)  end

      self.pages = [
        cover = Page.create(:title => 'Cover'),
        notes = Page.create(:title => 'Notes'),
        staff = Page.create(:title => 'Staff'),
        toc   = Page.create(:title => 'ToC'),
      ]
      toc.table_of_contents = TableOfContents.create
      staff.staff_list = StaffList.create

      published.each_slice(3) do |three_submissions|
        self.pages.create.submissions << three_submissions
      end
      self.pages.each do |page|
        page.submissions.each_with_index do |sub, i|
          sub.update_attribute :position, i + 1
        end
      end
    else
      raise MagazineStillAcceptingSubmissionsError, "You cannot publish a magazine that is still accepting submissions"
    end
  end

  def notification_sent?
    self.notification_sent
  end

  def notify_authors_of_published_magazine
    self.submissions(:all).group_by(&:email).each do |author_email, her_submissions|
      Notifications.delay.we_published_a_magazine(author_email, self, her_submissions)
    end
    self.update_attributes notification_sent: true
  end

  def page page_title
    if page_title.present?
      Page.find_by_magazine_id_and_title(self.id, page_title).presence || \
      Page.find_by_magazine_id_and_position(self.id, page_title.to_i + 4).presence || \
      self.pages.first
    else
      self.pages.first
    end
  end

  def create_page_at position
    page = self.pages.create
    page.insert_at position if position.present?
    page
  end

  class << self
    def current
      where(:accepts_submissions_from  < Date.today,
            :accepts_submissions_until > Date.today).first
    end
  end

  def published?
    published_on.present?
  end

  memoize :submissions, :average_score, :to_s

protected

  def accepts_from_after_latest_or_perhaps_today
    if self.accepts_submissions_from.blank?
      if Magazine.all.present?
        self.accepts_submissions_from = Magazine.order("accepts_submissions_until DESC").first.accepts_submissions_until
      else
        self.accepts_submissions_from = Date.today 
      end
    end
  end

  def accepts_until_six_months_later
    self.accepts_submissions_until = self.accepts_submissions_from + 6.months if self.accepts_submissions_until.blank?
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
      :accepts_submissions_from  < self.accepts_submissions_from,
      :accepts_submissions_until > self.accepts_submissions_from
    )
    if mags.present? && (mags.length > 1 || mags.first != self)
      then errors.add :accepts_submissions_from,  "can't occurr during another magazine"
    end
    mags = Magazine.where(
      :accepts_submissions_from  < self.accepts_submissions_until,
      :accepts_submissions_until > self.accepts_submissions_until
    )
    if mags.present? && (mags.length > 1 || mags.first != self)
      then errors.add :accepts_submissions_until, "can't occurr during another magazine"
    end
  end
end
