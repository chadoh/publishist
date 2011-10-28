# == Schema Information
# Schema version: 20110516234654
#
# Table name: packlets
#
#  id            :integer         not null, primary key
#  meeting_id    :integer
#  submission_id :integer
#  position      :integer
#  created_at    :datetime
#  updated_at    :datetime
#

class Packlet < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :submission, :include => :author

  has_many :scores
  has_one :magazine, through: :meeting

  acts_as_list :scope => :meeting

  validates_presence_of :meeting_id
  validates_presence_of :submission_id
  validates_uniqueness_of :submission_id, scope: :meeting_id

  validate :only_reviewed_in_one_magazine

  before_create :submission_reviewed_or_queued

  def destroy options = {}
    super()
    if self.submission.packlets.empty?
      self.submission.has_been :submitted, :by => options[:current_person]
    end
  end

protected

  def only_reviewed_in_one_magazine
    if self.meeting && self.magazine
      if self.submission.magazine != self.magazine
        errors.add(:submission, "can only be reviewed during the magazine it was submitted for")
      end
    end
  end

  def submission_reviewed_or_queued
    if self.meeting.datetime < Time.now + 3.hours
      self.submission.has_been :reviewed
    else
      self.submission.has_been :queued
    end
  end
end
