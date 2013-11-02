class PublicationCreator

  def initialize(options)
    @publication_name = options.fetch(:publication_name)
    @editor_email = options.fetch(:editor_email)
  end

  def create_publication
    @publication ||= Publication.create(
      name: publication_name,
      subdomain: publication_subdomain,
      meta_description: publication_description,
      publication_detail: PublicationDetail.create(
        about: publication_description,
      )
    )
  end
  alias :publication :create_publication

  def create_editor
    Person.create(
      email: editor_email,
      primary_publication: publication
    )
  end

  private

    attr_reader :publication_name, :editor_email

    def publication_subdomain
      publication_name.downcase.tr(' ','')
    end

    def publication_description
      "#{publication_name} is an awesome organization because we're made up of awesome people. We hope you like what you find."
    end

end
