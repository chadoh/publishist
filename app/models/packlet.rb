class Packlet < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :submission

  has_many :scores

  acts_as_list :scope => :meeting

  validates_presence_of :meeting_id
  validates_presence_of :submission_id

  validate :review_a_submission_only_once_per_meeting

  before_create :submission_reviewed_or_queued

  after_destroy "self.submission.has_been(:submitted) if self.submission.packlets.empty?"

protected

  def review_a_submission_only_once_per_meeting
    packlets = Packlet.find_all_by_submission_id_and_meeting_id(self.submission_id, self.meeting_id)
    if packlets.present? and (packlets.length > 1 or packlets.first != self)
      errors.add(:submission, "can only be review once per meeting")
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
