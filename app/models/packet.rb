class Packet < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :composition
  acts_as_list :scope => :meeting

  validates_presence_of :meeting_id
  validates_presence_of :composition_id
  validates_presence_of :position
end
