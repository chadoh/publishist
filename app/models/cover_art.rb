# == Schema Information
# Schema version: 20110903191625
#
# Table name: cover_arts
#
#  id                 :integer         not null, primary key
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  page_id            :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class CoverArt < ActiveRecord::Base
  belongs_to :page
end
