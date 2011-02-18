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
    packlets = Packlet.all
    for packlet in packlets
      if packlet.submission == self.submission && packlet.meeting == self.meeting
        errors.add(:submission, "can only be review once per meeting")
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
