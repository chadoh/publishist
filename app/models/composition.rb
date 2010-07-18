class Composition < ActiveRecord::Base
  validates_presence_of :body
  validates_uniqueness_of :body

  before_validation :anonymous_if_blank
  before_validation :untitled_if_blank
  #before_save :htmlize_line_breaks

protected

  def anonymous_if_blank
    self.author= "Anonymous" if self.author.blank?
  end
  def untitled_if_blank
    self.title= "untitled" if self.title.blank?
  end
  #def htmlize_line_breaks
    #body.gsub!(/(\r)?\n/, '<br>')
  #end
end
