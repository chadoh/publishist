class Publication < ActiveRecord::Base
  attr_accessible :address, :subdomain, :latitude, :longitude, :name, :tagline, :about, :meetings_info, :publication_detail_attributes

  has_many :magazines, dependent: :destroy
  has_many :submissions, dependent: :destroy
  has_many :people, foreign_key: "primary_publication_id"
  has_one  :publication_detail, dependent: :destroy

  validates_uniqueness_of :subdomain

  delegate :address, :latitude, :longitude, :about, :meetings_info, to: :publication_detail
  accepts_nested_attributes_for :publication_detail

  def editor
    ret = magazine_ids.each do |id|
      mag = Magazine.find(id).communicators.first
      break mag if mag
    end
    return ret if ret.present?
    raise NoEditorForPublication
  end
end

class NoEditorForPublication < RuntimeError; end
