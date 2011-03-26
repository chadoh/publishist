class Magazine < ActiveRecord::Base
  validates_presence_of :nickname
  validates_presence_of :accepts_submissions_from
  validates_presence_of :accepts_submissions_until
  validate :from_happens_before_until
  validate :magazine_ranges_dont_conflict

  after_initialize "self.nickname = 'next' if self.nickname.blank?"
  after_initialize :accepts_from_after_latest_or_perhaps_today
  after_initialize :accepts_until_six_months_later

  default_scope order("accepts_submissions_until DESC")

  has_many :meetings, :dependent => :nullify
  has_many :submissions, :through => :meetings

  def average_score
    packlet_ids = self.meetings.collect(&:packlets).flatten.collect &:id
    Score.average 'amount', :conditions => "packlet_id IN (#{packlet_ids.join ','})" unless packlet_ids.blank?
  end

  def highest_scores how_many = 50
    self.meetings.collect(&:submissions).flatten.uniq.sort {|a,b| b.average_score <=> a.average_score }.shift(how_many)
  end

  def present_name
    title.presence || "the #{nickname} magazine"
  end

  def publish array_of_winners
    if self.accepts_submissions_until > Time.now
      raise MagazineStillAcceptingSubmissionsError, "You cannot publish a magazine that is still accepting submissions"
    else
      self.update_attributes :published_on => Date.today
      for sub in array_of_winners
        sub.has_been :published
      end
      mag_subs = self.meetings.collect(&:submissions).flatten.uniq
      rejected = mag_subs - array_of_winners
      for sub in rejected
        sub.has_been :rejected
      end
    end
  end

  class << self
    def current
      where(:accepts_submissions_from  < Date.today,
            :accepts_submissions_until > Date.today).first
    end
  end

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
