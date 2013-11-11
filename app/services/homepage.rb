class Homepage
  def initialize(publication)
    issue = issue_for(publication)
    @hook = nil unless issue
    defined?(@hook) or @hook = submission_for(issue)
  end

  def hook(&block)
    yield(@hook) if @hook
  end

  def hook_present?
    !!@hook
  end

  private

    def issue_for(publication)
      publication.issues.
        published.
        order("random()").first
    end

    def submission_for(issue)
      issue.submissions.
        published.
        where("photo_file_name IS NULL").
        order("random()").first
    end
end
