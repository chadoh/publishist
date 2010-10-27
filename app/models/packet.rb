class Packet < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :composition
  acts_as_list :scope => :meeting

  validates_presence_of :meeting_id
  validates_presence_of :composition_id

  validate :review_a_composition_only_once_per_meeting

  def review_a_composition_only_once_per_meeting
    packets = Packet.all
    for packet in packets
      if packet.composition == self.composition && packet.meeting == self.meeting
        errors.add(:composition, "can only be review once per meeting")
      end
    end
  end
end
