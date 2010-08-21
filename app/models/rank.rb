class Rank < ActiveRecord::Base
  belongs_to :person, :touch => true, :autosave => true

  validates_format_of :rank_type, :with => /\A[0-3]\Z/,
    :message => "can only be a number from 0 to 3"

  #a person can be multiple ranks at once
  #unless! it is a rank_type of 2 or 3 (editors)
  #a person cannot be both editor and co-editor at once

  before_save :end_previous_editorships

  def end_previous_editorships
    if self.rank_type > 1
      unless self.id #for new ranks only, not for updates
        end_persons_current_editorship #Jim cannot be coeditor (2) still, after he is made editor (3)
        end_editorship_of_same_kind #Swati cannot be editor still, after she has promoted Jim to her position
      end
    end
  end

  def end_persons_current_editorship
    if self.person.editor?
      current_editorship = self.person.highest_rank
      current_editorship.update_attribute(:rank_end, self.rank_start)
    end
  end

  def end_editorship_of_same_kind
    other_editorship_of_kind = Rank.find(:first, :conditions => "rank_type=#{self.rank_type} AND rank_end IS NULL")
    other_editorship_of_kind.update_attribute(:rank_end, self.rank_start) if other_editorship_of_kind
  end
end
