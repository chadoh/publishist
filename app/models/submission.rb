# == Schema Information
# Schema version: 20111024105831
#
# Table name: submissions
#
#  id                 :integer         not null, primary key
#  title              :text
#  body               :text
#  author_name        :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  author_id          :integer
#  author_email       :string(255)
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  state              :integer(8)      default(0)
#  cached_slug        :string(255)
#  page_id            :integer
#  position           :integer
#  magazine_id        :integer
#

class Submission < ActiveRecord::Base
  include ActionView::Helpers::SanitizeHelper
  belongs_to :author, :class_name => "Person"
  belongs_to :page
  belongs_to :magazine
  has_many :packlets, dependent: :destroy
  has_many :meetings, through: :packlets
  has_many :scores,   through: :packlets
  has_attached_file :photo,
    :storage        => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path           => "/:style/:filename",
    :styles         => { medium: "510x510>" }
  has_friendly_id :to_slug, use_slug: true
  attr_accessor :updated_by

  acts_as_enum :state, [:draft, :submitted, :queued, :reviewed, :scored, :rejected, :published]
  acts_as_list scope: :page

  validates_length_of :title, maximum: 255
  validate "errors.add :author_email, 'must be filled in. Or you can sign in.'",
    :if => Proc.new {|s| s.author_id.blank? && s.author_email.blank? }
  validate "self.author_name = 'Anonymous'",
    :if => Proc.new {|s| s.author_id.blank? && s.author_name .blank? }
  validate "errors.add :body, 'cannot be blank.'",
    :if => Proc.new {|s| s.body.blank? && s.title.blank? }
  validates_attachment_content_type :photo,
    :content_type => [ 'image/png', 'image/jpeg', 'image/gif', 'image/svg+xml', 'image/tiff', 'image/vnd.microsoft.icon' ],
    :if           => Proc.new { |submission| submission.photo.file? },
    :message      => "must be an image"

  before_save      :published_if_for_a_published_magazine
  before_create    :set_position_to_nil
  after_find       :reviewed_if_meeting_has_occurred
  after_save       :notify_current_communicator_if_submitted
  after_create     :author_has_positions_with_the_disappears_ability
  after_initialize :magazine_is_current_if_blank

  scope :published, where(state: Submission.state(:published))

  def author_name
    @author_name ||= author.try(:name) || self[:author_name]
  end

  def author_first
    @author_first ||= if read_attribute(:author_id)
      @author ||= Person.find(read_attribute(:author_id))
      @author.first_name
    else
      author_name.split(' ').first
    end
  end

  def email
    @email ||= if read_attribute(:author_id)
      @author ||= Person.find(read_attribute(:author_id))
      @author.email
    else
      read_attribute(:author_email)
    end
  end

  def has_been moved_to_state, options = {}
    update_attributes :state => moved_to_state, updated_by: options[:by]
  end

  [:draft, :submitted, :queued, :reviewed, :scored, :published, :rejected].each do |state|
    define_method "#{state}?" do
      self.state == state
    end
  end

  def average_score
    @average_score ||= begin
      packlet_ids = self.packlets.collect &:id
      score = Score.average 'amount', :conditions => "packlet_id IN (#{packlet_ids.join ','})"
      (score * 100).round.to_f / 100
    end
  end

  def to_s
    @to_s ||= strip_tags(self.title).presence || strip_tags(self.body.try(:lines).try(:first))
  end

  def to_slug
    strip_tags(self.title).gsub(/[^0-9A-Z\s]/i, '').presence || strip_tags(self.body.lines.first)
  end

protected

  def reviewed_if_meeting_has_occurred
    if queued?
      if meetings.select {|m| m.datetime < Time.now + 3.hours }.present?
        update_attribute :state, Submission.state(:reviewed)
      end
    end
  end

  def set_position_to_nil
    self.position = nil
  end

  def published_if_for_a_published_magazine
    if !self.published? && self.magazine && self.magazine.published?
      self.state = :published
      self.magazine.pages.create unless self.magazine.page(1)
      self.page = self.magazine.page(1)
    end
  end

  def author_has_positions_with_the_disappears_ability
    if self.author && self.author.abilities.where(key: 'disappears').empty?
      self.author.positions << Position.joins(:abilities).where(abilities: { key: 'disappears'})
    end
  end

  def notify_current_communicator_if_submitted
    if state_changed? && state == :submitted && state_was == Submission.state(:draft)
      notify = updated_by.blank? || (editor = Person.current_communicators.first).blank? || editor != updated_by
      Notifications.new_submission(self).deliver if notify
    end
  end

  def magazine_is_current_if_blank
    self.magazine = Magazine.current if self.magazine.blank?
  end

end
