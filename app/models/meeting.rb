class Meeting < ActiveRecord::Base
  has_many :attendances, :dependent => :destroy
  has_many :people, :through => :attendances
  has_many :packets, :dependent => :destroy, :order => 'position'
  has_many :submissions, :through => :packets

  default_scope order("created_at DESC")

  def attendees_who_have_not_entered_scores_themselves
    #attendances.with_no_scores_entered_for_entire_meeting
    attendees_who_entered_scores = packets.collect(&:scores_not_entered_by_coeditor).flatten.collect(&:attendance).uniq
    attendances - attendees_who_entered_scores
  end
end
