class Magazine < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  validates_presence_of :nickname
  validates_presence_of :accepts_submissions_from
  validates_presence_of :accepts_submissions_until
  validate :from_happens_before_until
  validate :magazine_ranges_dont_conflict

  after_initialize "self.nickname = 'next' if self.nickname.blank?"
  after_initialize :accepts_from_after_latest_or_perhaps_today
  after_initialize :accepts_until_six_months_later

  default_scope order("accepts_submissions_until DESC")

  has_many :meetings, :dependent => :nullify, :include => :submissions

  # TODO: This should be a nested hm:t; waiting for Rails 3.1 which will allow this
  def submissions
    submission_ids = self.meetings.collect(&:packlets).flatten.collect(&:submission_id).uniq
    Submission.where :id + submission_ids
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
      all_submissions.group_by(&:email).each do |author_email, her_submissions|
        Notifications.we_published_a_magazine(author_email, self, her_submissions).try(:deliver)
        # TODO: figure out why the tests fails if we boldly deliver, instead of merely trying
      end
    else
      raise MagazineStillAcceptingSubmissionsError, "You cannot publish a magazine that is still accepting submissions"
    end
  end

  class << self
    def current
      where(:accepts_submissions_from  < Date.today,
            :accepts_submissions_until > Date.today).first
    end
  end

  memoize :submissions, :average_score

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
