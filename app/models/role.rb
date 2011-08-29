class Role < ActiveRecord::Base
  belongs_to :person
  belongs_to :position
  validates_presence_of :person_id
  validates_presence_of :position_id
  validates_uniqueness_of :person_id, scope: :position_id
end
