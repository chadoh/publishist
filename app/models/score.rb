class Score < ActiveRecord::Base
  belongs_to :packet
  belongs_to :attendance

  validates_presence_of :packet
  validates_presence_of :attendance
  validates_presence_of :amount
  validates_numericality_of :amount
  validates_inclusion_of :amount, :in => 1..10
  #validate :one_per_attendance_and_packet_combo

  class << self
    def with(attendance, packet, options = {})
      Score.where(
        :attendance_id => attendance.id,
        :packet_id => packet.id).first ||
      Score.new(
        :attendance => attendance,
        :packet => packet,
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

  def one_per_attendance_and_packet_combo
    @s = Score.where(
      :packet_id => packet_id,
      :attendance_id => attendance_id).first
    if @s && @s != self
      errors.add(:packet,
        "can only be scored once by each attendee to the meeting")
    end
  end
end
