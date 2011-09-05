# == Schema Information
# Schema version: 20110904221228
#
# Table name: cover_arts
#
#  id         :integer         not null, primary key
#  page_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class CoverArt < ActiveRecord::Base
  belongs_to :page
end
