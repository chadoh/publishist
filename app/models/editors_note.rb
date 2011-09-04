# == Schema Information
# Schema version: 20110903191625
#
# Table name: editors_notes
#
#  id         :integer         not null, primary key
#  page_id    :integer
#  title      :string(255)
#  body       :text
#  created_at :datetime
#  updated_at :datetime
#

class EditorsNote < ActiveRecord::Base
  belongs_to :page
end
