class StaffList < ActiveRecord::Base
  belongs_to :page
  has_one :magazine, through: :page
end
