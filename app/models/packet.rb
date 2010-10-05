class Packet < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :composition

  validates_presence_of :meeting_id
  validates_presence_of :composition_id
  validates_presence_of :position
end
