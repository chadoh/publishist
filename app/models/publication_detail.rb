class PublicationDetail < ActiveRecord::Base
  attr_accessible :about, :meetings_info, :address, :latitude, :longitude, :publication

  belongs_to :publication
end
