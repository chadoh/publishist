class Attendance < ActiveRecord::Base
  belongs_to :meeting
  belongs_to :person

  validates_presence_of :meeting_id
  validate :presence_of_person

  def first_name
    if self.person
      self.person.first_name
    elsif self.person_name
      self.person_name.split(' ').first
    end
  end

protected
  
  def presence_of_person
    if self.person.blank? and self.person_name.blank?
      errors.add :person, "can't be blank"
    end
    if self.person and self.person_name
      errors.add :person, "... you've included a person and an unregistered person's name... I'm not sure how that's possible, but there it is."
    end
  end
end
