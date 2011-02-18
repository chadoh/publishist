class Submission < ActiveRecord::Base
  belongs_to :author, :class_name => "Person"
  has_many :packlets, :dependent => :destroy
  has_many :meetings, :through => :packlets
  has_many :scores, :through => :packlets

  before_validation :remove_ms_word_kruft

  validate :author_email_exists_if_user_not_signed_in
  #validate :if_associated_to_Person_dont_allow_name_or_email_also

  after_find :reviewed_if_meeting_has_occurred
  after_update :send_notification_email_if_submitted

  acts_as_enum :state, [:draft, :submitted, :queued, :reviewed, :scored, :rejected, :published]

  validates_attachment_content_type :photo, 
    :content_type => [ 'image/png', 'image/jpeg', 'image/gif', 'image/svg+xml', 'image/tiff', 'image/vnd.microsoft.icon' ],
    :if => Proc.new { |submission| submission.photo.file? },
    :message => "must be an image"

  has_attached_file :photo,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "/:style/:filename",
    :styles => { :medium => "510x510>" }

  def author_name
    if read_attribute :author_id
      Person.find(read_attribute(:author_id)).name
    else
      read_attribute :author_name
    end
  end

  def author_first
    if read_attribute(:author_id)
      Person.find(read_attribute(:author_id)).first_name
    else
      author_name.split(' ').first
    end
  end

  def email
    if read_attribute(:author_id)
      Person.find(read_attribute(:author_id)).email
    else
      read_attribute(:author_email)
    end
  end

  def has_been moved_to_state
    update_attribute :state, moved_to_state
  end

  [:draft, :submitted, :queued, :reviewed, :scored, :published, :rejected].each do |state|
    define_method "#{state}?" do
      self.state == state
    end
  end

  def average_score
    packlet_ids = self.packlets.collect &:id
    Score.average 'amount', :conditions => "packlet_id IN (#{packlet_ids.join ','})"
  end

protected

  def remove_ms_word_kruft
    self.body = self.body.gsub(/<!--\[if (g|l)te? mso [0-9]+\]>.+?<!\[endif\]-->/, '')
  end

  def author_email_exists_if_user_not_signed_in
    unless read_attribute(:author_id)
      author_anonymous_if_blank
      verify_author_email_exists
    end
  end

  def verify_author_email_exists
    errors.add(:author_email, "must be filled in (unless you sign in!). We need to be able to contact someone with questions, you see.") unless author_email.present?
  end

  def author_anonymous_if_blank
    unless !!self.author
      self.author_name = "Anonymous" if self.author_name.blank?
    end
  end

  def if_associated_to_Person_dont_allow_name_or_email_also
    if author_email.present? && author_id.present?
      errors.add(:author_email, "... Now, it's confusing to have both this and to add a full-fledged, account-holding individual. To avoid confusion, please only fill in one.")
    elsif !!read_attribute(:author_name) && !!author
      errors.add(:author_name, "... Now, it's confusing to have both this and to add a full-fledged, account-holding individual. To avoid confusion, please only fill in one.")
    end
  end

  def reviewed_if_meeting_has_occurred
    if queued?
      if meetings.select {|m| m.datetime < Time.now + 3.hours }.present?
        update_attribute :state, Submission.state(:reviewed)
      end
    end
  end

  def send_notification_email_if_submitted
    Notifications.new_submission(self).deliver if submitted?
  end

end
