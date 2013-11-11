class Publication < ActiveRecord::Base
  attr_accessible :address, :subdomain, :latitude, :longitude, :name, :tagline,
    :about, :meetings_info, :publication_detail_attributes, :custom_domain,
    :meta_description, :publication_detail

  has_many :issues, dependent: :destroy, inverse_of: :publication
  has_many :submissions, dependent: :destroy
  has_many :people, foreign_key: "primary_publication_id"
  has_many :meetings, through: :issues
  has_one  :publication_detail, dependent: :destroy

  validates_uniqueness_of :subdomain

  delegate :address, :latitude, :longitude, :about, :meetings_info, to: :publication_detail
  accepts_nested_attributes_for :publication_detail

  def editor
    @editor ||= first_communicator
    @editor ||= people.first
    @editor ||= OpenStruct.new email: "chad+unknown.editor@publishist.com"
  end

  def current_issue
    actual_current_issue || issues.first
  end

  def current_issue!
    actual_current_issue || issues.create
  end

  def to_s
    name
  end

  private

  def first_communicator
    @first_communicator ||= issue_ids.each do |id|
      communicator = Issue.find(id).communicators.first
      break communicator if communicator
    end
    return @first_communicator unless @first_communicator.is_a?(Array)
  end

  def actual_current_issue
    issues.where(
      'accepts_submissions_from  <= :today AND ' + \
      'accepts_submissions_until >= :today',
      today: Time.zone.now
    ).first
  end
end
