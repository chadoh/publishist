class CoverArt < ActiveRecord::Base
  belongs_to :page
  has_attached_file :image,
    :storage        => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path           => "/cover_art/:style/:filename",
    :styles         => { thumb: "48x48" }
end
