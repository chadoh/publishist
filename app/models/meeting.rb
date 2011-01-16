class Meeting < ActiveRecord::Base
  has_many :attendees, :dependent => :destroy
  has_many :people, :through => :attendees
  has_many :packlets, :dependent => :destroy, :order => 'position'
  has_many :submissions, :through => :packlets

  default_scope order("created_at DESC")

  def attendees_who_have_not_entered_scores_themselves
    #attendees.with_no_scores_entered_for_entire_meeting
    attendees_who_entered_scores = packlets.collect(&:scores_not_entered_by_coeditor).flatten.collect(&:attendee).uniq
    attendees - attendees_who_entered_scores
  end
end
