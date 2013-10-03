class Publication < ActiveRecord::Base
  attr_accessible :address, :domain, :latitude, :longitude, :name, :tagline

  has_many :magazines
  has_many :submissions

  validates_uniqueness_of :domain
end
