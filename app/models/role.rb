# == Schema Information
# Schema version: 20110903191625
#
# Table name: roles
#
#  id          :integer         not null, primary key
#  person_id   :integer
#  position_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class Role < ActiveRecord::Base
  belongs_to :person
  belongs_to :position
  has_one :magazine, through: :position
  validates_presence_of :person_id
  validates_presence_of :position_id
  validates_uniqueness_of :person_id, scope: :position_id
end
