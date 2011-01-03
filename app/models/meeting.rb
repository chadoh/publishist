class Meeting < ActiveRecord::Base
  has_many :attendances, :dependent => :destroy
  has_many :people, :through => :attendances
  has_many :packets, :dependent => :destroy, :order => 'position'
  has_many :submissions, :through => :packets

  default_scope order("created_at DESC")
end
