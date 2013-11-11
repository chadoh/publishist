# == Schema Information
# Schema version: 20110903191625
#
# Table name: staff_lists
#
#  id         :integer         not null, primary key
#  page_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class StaffList < ActiveRecord::Base
  belongs_to :page
  has_one :issue, through: :page
end
