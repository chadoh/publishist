# == Schema Information
# Schema version: 20110516234654
#
# Table name: scores
#
#  id                  :integer         not null, primary key
#  amount              :integer
#  attendee_id         :integer
#  packlet_id          :integer
#  entered_by_coeditor :boolean
#  created_at          :datetime
#  updated_at          :datetime
#

class Score < ActiveRecord::Base
  belongs_to :packlet
  belongs_to :attendee
  has_one :meeting, :through => :packlet

  validates_presence_of :packlet
  validates_presence_of :attendee
  validates_presence_of :amount
  validate :one_per_attendee_and_packlet_combo

  after_create :increment_magazines_counters

  after_save "packlet.submission.has_been :scored"
  after_destroy "packlet.submission.has_been :reviewed if packlet.submission.scores.empty? && packlet.submission.scored?"
  after_destroy :reduce_magazines_counters

  def amount=(number)
    if number.present?
      number = number.to_i
      number = 1 if number < 1
      number = 10 if number > 10

      mag = self.packlet.try(:meeting).try(:magazine)
      mag.update_attributes(
        'sum_of_scores' => mag.sum_of_scores - self.amount + number
      ) if mag.try(:sum_of_scores).present? && self.amount.present?

      write_attribute :amount, number
    end
  end

  class << self
    def with(attendee, packlet, options = {})
      score = Score.where( :attendee_id => attendee.id, :packlet_id => packlet.id).first
      return score if score.present?
      Score.new(
        :attendee => attendee,
        :packlet => packlet,
        :entered_by_coeditor => options[:entered_by_coeditor] || false)
    end
  end

  def update_attributes(attributes)
    if attributes['amount'].blank?
      self.destroy
    else
      super
    end
  end

protected

  def destroy_if_amount_is_blank
    if amount.blank? and id.present?
      self.destroy
    end
  end

  def one_per_attendee_and_packlet_combo
    @s = Score.where(
      :packlet_id => packlet_id,
      :attendee_id => attendee_id).first
    if @s && @s != self
      errors.add(:packlet,
        "can only be scored once by each attendee to the meeting")
    end
  end

  def increment_magazines_counters
    mag = self.packlet.meeting.magazine
    mag.update_attributes(
      :count_of_scores => mag.count_of_scores + 1,
      :sum_of_scores   => mag  .sum_of_scores + self.amount
    ) if mag.present?
  end

  def reduce_magazines_counters
    mag = self.packlet.meeting.magazine
    mag.update_attributes(
      :count_of_scores => mag.count_of_scores - 1,
      :sum_of_scores   => mag  .sum_of_scores - self.amount
    ) if mag.present?
  end
end
