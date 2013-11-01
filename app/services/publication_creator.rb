class PublicationCreator
  def initialize(options)
    @publication_name = options.fetch(:publication_name)
  end

  def create_publication
    Publication.create(
      name: publication_name,
      subdomain: publication_subdomain,
      meta_description: "#{publication_name} is an awesome organization. Definitely check them out.",
    )
  end

  private

    attr_reader :publication_name

    def publication_subdomain
      publication_name.downcase.tr(' ','')
    end

end
