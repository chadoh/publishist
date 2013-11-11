# == Schema Information
# Schema version: 20110903191625
#
# Table name: positions
#
#  id          :integer         not null, primary key
#  issue_id :integer
#  name        :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Position < ActiveRecord::Base
  belongs_to :issue
  has_many :roles, dependent: :destroy
  has_many :people, through: :roles
  has_many :position_abilities, dependent: :destroy
  has_many :abilities, through: :position_abilities

  validates_presence_of :name
  validates_presence_of :issue_id

  def to_s
    name
  end
end
