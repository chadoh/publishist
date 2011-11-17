class Pseudonym < ActiveRecord::Base
  belongs_to :submission

  validates_presence_of :name
end
