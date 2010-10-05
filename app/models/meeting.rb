class Meeting < ActiveRecord::Base
  has_many :attendances, :dependent => :destroy
  has_many :people, :through => :attendances
  has_many :packets, :dependent => :destroy
  has_many :compositions, :through => :packets
end
