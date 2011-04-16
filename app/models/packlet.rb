class Packlet < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :submission, :include => :author

  has_many :scores

  acts_as_list :scope => :meeting

  validates_presence_of :meeting_id
  validates_presence_of :submission_id

  validate :review_a_submission_only_once_per_meeting
  validate :only_reviewed_in_one_magazine

  before_create :submission_reviewed_or_queued

  def destroy options = {}
    super()
    if self.submission.packlets.empty? && !(options[:current_person] == Person.editor)
      self.submission.has_been(:submitted)
    end
  end

protected

  def only_reviewed_in_one_magazine
    if !!self.meeting && !!self.meeting.magazine
      if (self.submission.meetings.collect(&:magazine) - [self.meeting.try(:magazine)]).present?
        errors.add(:submission, "can only be reviewed in one magazine")
      end
    end
  end

  def review_a_submission_only_once_per_meeting
    packlets = Packlet.find_all_by_submission_id_and_meeting_id(self.submission_id, self.meeting_id)
    if packlets.present? and (packlets.length > 1 or packlets.first != self)
      errors.add(:submission, "can only be reviewed once per meeting")
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
