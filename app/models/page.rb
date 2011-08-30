# == Schema Information
# Schema version: 20110516234654
#
# Table name: pages
#
#  id          :integer         not null, primary key
#  magazine_id :integer
#  position    :integer
#  title       :string(255)
#  created_at  :datetime
#  updated_at  :datetime
#

class Page < ActiveRecord::Base
  extend ActiveSupport::Memoizable

  belongs_to :magazine
  has_many   :submissions,       dependent: :nullify, order: :position
  has_one    :cover_art,         dependent: :destroy
  has_one    :table_of_contents, dependent: :destroy
  has_one    :staff_list,        dependent: :destroy
  has_many   :editors_notes,     dependent: :destroy
  validates_presence_of :magazine_id

  acts_as_list scope: :magazine

  def title
    read_attribute(:title).presence || (self.position - 4).to_s
  end

  def to_param
    self.title.downcase
  end

  def has_content?
    submissions.present?       || \
    cover_art.present?         || \
    editors_notes.present?     || \
    table_of_contents.present? || \
    staff_list.present?
  end

  memoize :has_content?, :title
end
