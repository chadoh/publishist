class Magazine < ActiveRecord::Base
  validates_presence_of :nickname
  validates_presence_of :accepts_submissions_from
  validates_presence_of :accepts_submissions_until

  after_initialize "self.nickname = 'next'"
  after_initialize "self.accepts_submissions_from = Date.today"
  after_initialize "self.accepts_submissions_until = Date.today + 6.months"

  default_scope order("accepts_submissions_until DESC")
end
