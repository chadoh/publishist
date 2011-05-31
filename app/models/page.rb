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
  has_many   :submissions, :dependent => :nullify
  validates_presence_of :magazine_id

  acts_as_list :scope => :magazine

  def title
    read_attribute(:title).presence || (self.position - 4).to_s
  end

  memoize :title
end
