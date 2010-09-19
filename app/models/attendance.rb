class Attendance < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :person

  validates_presence_of :meeting_id
  validates_presence_of :person_id
end
