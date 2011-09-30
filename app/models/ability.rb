class Ability < ActiveRecord::Base
  has_many :position_abilities
  has_many :positions, through: :position_abilities
  has_many :roles, through: :positions
  has_many :people, through: :roles

  validates_presence_of :key
  validates_presence_of :description

  default_scope order(:id)

  def to_s
    key.humanize.downcase
  end
end
