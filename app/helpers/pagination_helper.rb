module PaginationHelper
  extend ActiveSupport::Memoizable

  def pages_for magazine
    for page in magazine.pages
    end
  end
end
