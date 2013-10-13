class Publication < ActiveRecord::Base
  attr_accessible :address, :subdomain, :latitude, :longitude, :name, :tagline, :about, :meetings_info, :publication_detail_attributes

  has_many :magazines, dependent: :destroy, inverse_of: :publication
  has_many :submissions, dependent: :destroy
  has_many :people, foreign_key: "primary_publication_id"
  has_one  :publication_detail, dependent: :destroy

  validates_uniqueness_of :subdomain

  delegate :address, :latitude, :longitude, :about, :meetings_info, to: :publication_detail
  accepts_nested_attributes_for :publication_detail

  def editor
    @editor ||= magazine_ids.each do |id|
      communicator = Magazine.find(id).communicators.first
      break communicator if communicator
    end
    return @editor unless @editor.is_a?(Array)
    @editor = OpenStruct.new email: "chad+unknown.editor@publishist.com"
  end
end
