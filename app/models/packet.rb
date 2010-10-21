class Packet < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :composition
  acts_as_list :scope => :meeting

  validates_presence_of :meeting_id
  validates_presence_of :composition_id

  validate :review_a_composition_only_once_per_meeting

  def review_a_composition_only_once_per_meeting
    packets = Packet.all
    packets.delete(self)
    compositions = packets.collect(&:composition)
    meetings = packets.collect(&:meeting)
    if compositions.include?(self.composition) and meetings.include?(self.meeting)
      errors.add(:composition, "can only be reviewed once at each meeting")
    end
  end
end
