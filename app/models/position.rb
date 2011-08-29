class Position < ActiveRecord::Base
  belongs_to :magazine
  has_many :roles, dependent: :destroy
  has_many :people, through: :roles

  validates_presence_of :name
  validates_presence_of :magazine_id
end
