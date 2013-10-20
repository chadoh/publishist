# utilities to help with formatting submissions on the home page
module HookSubmission
  def truncated?
    self[:body].length > 200
  end

  def body
    if truncated?
      self[:body][0..200]
    else
      self[:body]
    end
  end
end
