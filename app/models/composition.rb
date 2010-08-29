class Composition < ActiveRecord::Base
  belongs_to :author, :class_name => "Person"

  before_validation :untitled_if_blank

  validate :author_email_exists_if_user_not_signed_in

  has_attached_file :photo,
    :storage => :s3,
    :s3_credentials => "#{Rails.root}/config/s3.yml",
    :path => "/:style/:filename",
    :styles => { :medium => "500x500>" }

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

  def author_email
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
end
