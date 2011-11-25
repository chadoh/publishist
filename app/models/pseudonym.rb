# == Schema Information
# Schema version: 20111116015113
#
# Table name: pseudonyms
#
#  id              :integer         not null, primary key
#  name            :string(255)
#  link_to_profile :boolean         default(TRUE)
#  submission_id   :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class Pseudonym < ActiveRecord::Base
  belongs_to :submission

  validates_presence_of :name

  def to_s
    name
  end
end
