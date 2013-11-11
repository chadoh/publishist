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
  has_one :issue, through: :meeting

  acts_as_list :scope => :meeting

  validates_presence_of :meeting_id
  validates_presence_of :submission_id
  validates_uniqueness_of :submission_id, scope: :meeting_id

  validate :only_reviewed_in_one_issue

  before_create :submission_reviewed_or_queued
  before_save   :update_submissions_issue_if_different

  def destroy options = {}
    super()
    if self.submission.packlets.empty?
      self.submission.has_been :submitted, :by => options[:current_person]
    end
  end

protected

  def only_reviewed_in_one_issue
    if self.meeting && self.issue
      if Packlet.where(submission_id: self.submission).present?
        if self.submission.issue != self.issue
          errors.add(:submission, "can only be reviewed during the issue it was submitted for")
        end
      end
    end
  end

  def update_submissions_issue_if_different
    if self.meeting && self.issue
      if self.submission.issue != self.issue
        self.submission.update_attributes issue: self.issue
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
