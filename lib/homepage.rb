class Homepage
  def initialize(publication)
    magazine = publication.magazines.published.order("random()").first
    @hook = nil unless magazine
    defined?(@hook) or @hook = loop do
      hook = magazine.submissions.published.order("random()").first
      break hook unless hook.photo?
    end
  end

  def hook(&block)
    yield(@hook) if @hook
  end
end
