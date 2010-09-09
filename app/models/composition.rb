class Composition < ActiveRecord::Base
  belongs_to :author, :class_name => "Person"

  before_validation :untitled_if_blank

  validate :author_email_exists_if_user_not_signed_in
  validate :if_associated_to_Person_dont_allow_name_or_email_also

  validates_attachment_content_type :photo, 
    :content_type => [ 'image/png', 'image/jpeg', 'image/gif', 'image/svg+xml', 'image/tiff', 'image/vnd.microsoft.icon' ],
    :if => Proc.new { |composition| composition.photo.file? },
    :message => "must be an image"

  has_attached_file :photo,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "/:style/:filename",
    :styles => { :medium => "510x510>" }

  def author
    if read_attribute(:author_id)
      Person.find(read_attribute(:author_id)).name
    else
      author_name
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

protected

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
    self.author_name = "Anonymous" if self.author.blank?
  end
  def untitled_if_blank
    self.title= "untitled" if self.title.blank?
  end
  def if_associated_to_Person_dont_allow_name_or_email_also
    if author_email.present? && author_id.present?
      errors.add(:author_email, "... Now, it's confusing to have both this and to add a full-fledged, account-holding individual. To avoid confusion, please only fill in one.")
    elsif author_name.present? && author_id.present?
      errors.add(:author_name, "... Now, it's confusing to have both this and to add a full-fledged, account-holding individual. To avoid confusion, please only fill in one.")
    end
  end
end
