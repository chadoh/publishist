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
