class TableOfContents < ActiveRecord::Base
  belongs_to :page
  has_one :magazine, through: :page

  def hash
    self.magazine.submissions.sort_by{|s| s.page.position }.inject({}) do |toc, submission|
      toc[submission] = {author: submission.author.presence || submission.author_name, page: submission.page}
      toc
    end
  end
end
