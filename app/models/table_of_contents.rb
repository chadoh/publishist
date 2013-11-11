# == Schema Information
# Schema version: 20110903191625
#
# Table name: table_of_contents
#
#  id         :integer         not null, primary key
#  page_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class TableOfContents < ActiveRecord::Base
  belongs_to :page
  has_one :issue, through: :page

  def to_h
    self.issue.submissions.sort_by{|s| s.page.position }.reverse.inject({}) do |toc, sub|
      toc[sub] = {page: sub.page}
      toc
    end
  end
end
