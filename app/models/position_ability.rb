# == Schema Information
# Schema version: 20111024105831
#
# Table name: position_abilities
#
#  id          :integer         not null, primary key
#  position_id :integer
#  ability_id  :integer
#  created_at  :datetime
#  updated_at  :datetime
#

class PositionAbility < ActiveRecord::Base
  belongs_to :position
  belongs_to :ability
  has_one :issue, through: :position
  validates_presence_of :position_id
  validates_presence_of :ability_id
end
