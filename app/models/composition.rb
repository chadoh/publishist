class Composition < ActiveRecord::Base
  belongs_to :author, :class_name => "Person"

  before_validation :untitled_if_blank

  validate :author_email_exists_if_user_not_signed_in
  validates_presence_of :body
  validates_uniqueness_of :body

protected

  def author_email_exists_if_user_not_signed_in
    unless self.author
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
