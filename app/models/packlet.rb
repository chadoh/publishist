class Packlet < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :submission

  has_many :scores

  acts_as_list :scope => :meeting

  validates_presence_of :meeting_id
  validates_presence_of :submission_id

  validate :review_a_submission_only_once_per_meeting

  def review_a_submission_only_once_per_meeting
    packlets = Packlet.all
    for packlet in packlets
      if packlet.submission == self.submission && packlet.meeting == self.meeting
        errors.add(:submission, "can only be review once per meeting")
      end
    end
  end

  def scores_not_entered_by_coeditor
    scores.select{ |s| s.entered_by_coeditor == false }.flatten
  end
end
