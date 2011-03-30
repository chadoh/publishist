class Meeting < ActiveRecord::Base
  has_many :attendees, :dependent => :destroy
  has_many :people, :through => :attendees
  has_many :packlets, :dependent => :destroy, :order => 'position', :include => :submission
  has_many :submissions, :through => :packlets

  belongs_to :magazine

  default_scope order("datetime ASC")

  after_save :submissions_have_been_reviewed_or_queued

  before_create :belongs_to_a_magazine

protected

  def belongs_to_a_magazine
    unless self.magazine.present?
      mag = Magazine.where(
        :accepts_submissions_from  < self.datetime,
        :accepts_submissions_until > self.datetime
      ).first
      self.magazine = mag.presence || Magazine.order("accepts_submissions_until DESC").first
    end
  end

  def submissions_have_been_reviewed_or_queued
    if datetime < Time.now + 3.hours
      self.submissions.each do |s|
        s.has_been :reviewed if s.queued?
      end
    else
      self.submissions.each do |s|
        s.has_been :queued if s.reviewed?
      end
    end
  end
end
