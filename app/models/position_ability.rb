class PositionAbility < ActiveRecord::Base
  belongs_to :position
  belongs_to :ability
  has_one :magazine, through: :position
  validates_presence_of :position_id
  validates_presence_of :ability_id
end
