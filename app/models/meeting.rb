class Meeting < ActiveRecord::Base
  has_many :attendees, :dependent => :destroy
  has_many :people, :through => :attendees
  has_many :packlets, :dependent => :destroy, :order => 'position'
  has_many :submissions, :through => :packlets

  default_scope order("created_at DESC")

  after_save :submissions_have_been_reviewed_or_queued

  def attendees_who_have_not_entered_scores_themselves
    attendees_who_entered_scores = packlets.collect(&:scores_not_entered_by_coeditor).flatten.collect(&:attendee).uniq
    attendees - attendees_who_entered_scores
  end
protected

  def submissions_have_been_reviewed_or_queued
    if datetime < Time.now + 3.hours
      self.submissions.each {|s| s.has_been :reviewed }
    else
      self.submissions.each {|s| s.has_been :queued }
    end
  end
end
