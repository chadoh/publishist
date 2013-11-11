class Attendee < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :person
  has_one    :issue, through: :meeting
  has_many   :scores

  validates_presence_of :meeting_id
  validate :presence_of_person

  default_scope order 'created_at'

  after_create :person_has_positions_with_the_disappears_ability

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

  def person_has_positions_with_the_disappears_ability
    unless self.person.blank? || self.person.abilities.collect(&:key).include?('disappears')
      self.person.positions << Position.joins(:abilities).where(abilities: { key: 'disappears'})
    end
  end
end
