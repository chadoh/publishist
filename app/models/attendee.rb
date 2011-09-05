# == Schema Information
# Schema version: 20110516234654
#
# Table name: attendees
#
#  id          :integer         not null, primary key
#  meeting_id  :integer
#  person_id   :integer
#  answer      :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#  person_name :string(255)
#

class Attendee < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :person

  has_many :scores

  validates_presence_of :meeting_id
  validate :presence_of_person

  default_scope order 'created_at'

  def first_name
    if self.person
      self.person.first_name
    elsif self.person_name
      self.person_name.split(' ').first
    end
  end

  def name
    if self.person
      self.person.name
    elsif self.person_name
      self.person_name
    end
  end

  def name_and_email
    if self.person
      self.person.name_and_email
    else
      self.person_name
    end
  end

protected

  def presence_of_person
    if self.person.blank? and self.person_name.blank?
      errors.add :person, "can't be blank"
    end
  end
end
