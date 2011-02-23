class Magazine < ActiveRecord::Base
  validates_presence_of :nickname
  validates_presence_of :accepts_submissions_from
  validates_presence_of :accepts_submissions_until
  validate :from_happens_before_until

  after_initialize "self.nickname = 'next' if self.nickname.blank?"
  after_initialize "self.accepts_submissions_from = Date.today if self.accepts_submissions_from.blank?"
  after_initialize "self.accepts_submissions_until = Date.today + 6.months if self.accepts_submissions_until.blank?"

  default_scope order("accepts_submissions_until DESC")

protected
  
  def from_happens_before_until
    if !!self.accepts_submissions_until && !!self.accepts_submissions_from
      if self.accepts_submissions_until <= self.accepts_submissions_from
        errors.add(:accepts_submissions_until, "must come after \"Accepts submissions from\"")
      end
    end
  end
end
