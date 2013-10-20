require 'hook_submission'

class Homepage
  def initialize(publication)
    @hook = publication.submissions.published.order("random()").first
    @hook.extend HookSubmission
  end

  def hook(&block)
    yield(@hook)
  end
end
