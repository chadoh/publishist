class Score < ActiveRecord::Base
  belongs_to :packlet
  belongs_to :attendee

  validates_presence_of :packlet
  validates_presence_of :attendee
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_inclusion_of :amount, :in => 1..10
  #validate :one_per_attendee_and_packlet_combo

  after_save "packlet.submission.has_been :scored"

  class << self
    def with(attendee, packlet, options = {})
      Score.where(
        :attendee_id => attendee.id,
        :packlet_id => packlet.id).first ||
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
end
