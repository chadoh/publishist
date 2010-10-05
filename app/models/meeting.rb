class Meeting < ActiveRecord::Base
  has_many :attendances, :dependent => :destroy
  has_many :people, :through => :attendances
end
