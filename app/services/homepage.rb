class Homepage
  def initialize(publication)
    magazine = magazine_for(publication)
    @hook = nil unless magazine
    defined?(@hook) or @hook = submission_for(magazine)
  end

  def hook(&block)
    yield(@hook) if @hook
  end

  def hook_present?
    !!@hook
  end

  private

    def magazine_for(publication)
      publication.magazines.
        published.
        order("random()").first
    end

    def submission_for(magazine)
      magazine.submissions.
        published.
        where("photo_file_name IS NULL").
        order("random()").first
    end
end
