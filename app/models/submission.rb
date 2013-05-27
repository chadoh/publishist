# == Schema Information
# Schema version: 20111121123428
#
# Table name: submissions
#
#  id                 :integer         not null, primary key
#  title              :text
#  body               :text
#  created_at         :datetime
#  updated_at         :datetime
#  author_id          :integer
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
  has_one  :pseudonym, dependent: :destroy
  has_attached_file :photo,
    :storage        => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path           => "/:style/:filename",
    :styles         => { medium: "510x510>" }
  extend FriendlyId
  friendly_id :to_slug, :use => [:slugged, :history]
  attr_accessor :updated_by

  acts_as_enum :state, [:draft, :submitted, :queued, :reviewed, :scored, :rejected, :published]
  acts_as_list scope: :page

  validate :author_present
  validate "errors.add :body, 'cannot be blank.'",
    :if => Proc.new {|s| s.body.blank? && s.title.blank? }
  validates_attachment_content_type :photo,
    :content_type => [ 'image/png', 'image/jpeg', 'image/gif', 'image/svg+xml', 'image/tiff', 'image/vnd.microsoft.icon' ],
    :if           => Proc.new { |submission| submission.photo.file? },
    :message      => "must be an image"

  before_save      :published_if_for_a_published_magazine, unless: 'state_was == Submission.state(:published)' # if being rejected
  before_save      :set_page_and_position
  before_create    :set_position_to_nil
  before_create    :create_author_if_blank
  after_find       :reviewed_if_meeting_has_occurred
  after_save       :notify_current_communicator_if_submitted
  after_create     :author_has_positions_with_the_disappears_ability
  after_initialize :magazine_is_current_if_blank

  scope :published, where(state: Submission.state(:published))

  attr_writer :author_name
  attr_writer :author_email
  def author_name
    @author_name ||= pseudonym.try(:name).presence || author.try(:name) || ''
  end
  def author_email
    @author_email ||= author.try(:email) || ''
  end
  alias :email :author_email

  def pseudonym_name
    self.pseudonym.try(:name)
  end
  def pseudonym_link
    if self.pseudonym
      self.pseudonym.link_to_profile
    else
      true
    end
  end
  def pseudonym_name=(a_string)
    if self.pseudonym
      self.pseudonym.update_attributes name: a_string
    elsif a_string.present?
      self.pseudonym = Pseudonym.create name: a_string
    end
  end
  def pseudonym_link=(a_boolean)
    if self.pseudonym
      self.pseudonym.update_attributes link_to_profile: a_boolean
    end
  end

  def author_first
    @author_first ||= if read_attribute(:author_id)
      @author ||= Person.find(read_attribute(:author_id))
      @author.first_name
    else
      author_name.split(' ').first
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
      packlet_ids = self.packlets.collect(&:id)
      unless packlet_ids.empty?
        score = Score.average 'amount', :conditions => "packlet_id IN (#{packlet_ids.join ','})"
        (score * 100).round.to_f / 100
      end
    end
  end

  def to_s
    @to_s ||= strip_tags(self.title).presence || strip_tags(self.body.try(:lines).try(:first))
  end

  def to_slug
    strip_tags(self.title).gsub(/[^0-9A-Z\s]/i, '').presence || strip_tags(self.body.lines.first)
  end

protected

  def author_present
    unless author_id.present? || (author_name.present? && author_email.present?)
      errors.add :author_name, "cannot be blank" if author_name.blank?
      errors.add :author_email, "cannot be blank" if author_email.blank?
    end
  end

  def create_author_if_blank
    if self.author.blank?
      person = Person.find_by_email(author_email).presence || \
               Person.create(name: author_name, email: author_email)
      self.author = person
      self.pseudonym_name = author_name if author_name != person.name
      Notifications.submitted_while_not_signed_in(self).deliver
    end
  end

  def reviewed_if_meeting_has_occurred
    if queued?
      if meetings.select {|m| m.datetime < Time.now + 3.hours }.present?
        update_attribute :state, Submission.state(:reviewed)
      end
    end
  end

  def published_if_for_a_published_magazine
    if !self.published? && self.magazine && self.magazine_id != self.magazine_id_was && self.magazine.published_on.present?
      self.state = :published
    end
  end

  def set_page_and_position
    if published? && magazine && magazine.published_on.present?
      unless self.page
        magazine.pages.create unless magazine.page(1)
        self.page = magazine.page(1) || magazine.pages.first
      end
      unless self.position
        self.position = page.submissions.count
      end
    end
    if !self.published?
      self.page = nil
      self.position = nil
    end
  end

  # needed to override the before_create that acts_as_list adds
  def set_position_to_nil
    self.position = nil if !self.published?
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
    unless self.magazine_id.present?
      self.magazine = Magazine.current!
    end
  end

end
