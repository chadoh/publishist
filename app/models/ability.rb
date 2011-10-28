# == Schema Information
# Schema version: 20111024105831
#
# Table name: abilities
#
#  id          :integer         not null, primary key
#  key         :string(255)
#  description :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Ability < ActiveRecord::Base
  has_many :position_abilities
  has_many :positions, through: :position_abilities
  has_many :roles,     through: :positions
  has_many :people,    through: :roles

  validates_presence_of :key
  validates_presence_of :description

  default_scope order(:id)

  def to_s
    key.humanize.downcase
  end
end
