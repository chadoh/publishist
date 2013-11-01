require 'spec_helper'
require 'publication_creator'

describe PublicationCreator do
  let(:publication_name) { "Fancy Prance" }
  let(:editor_email) { "hello@there.you" }
  let(:creator) { PublicationCreator.new(publication_name: publication_name, editor_email: editor_email) }
  it "is instantiated with a hash" do
    expect(creator).to be_kind_of PublicationCreator
  end

  describe "#create_publication" do
    let(:publication) { creator.create_publication }
    it "returns the publication that it creates" do
      expect(publication).to be_kind_of Publication
    end
    it "names the publication with the name it was instantiated with" do
      expect(publication.name).to eq publication_name
    end
    it "sets the subdomain to an all-lowercase, oneword version of its name" do
      expect(publication.subdomain).to eq "fancyprance"
    end
    it "sets the meta_description to some happy boilerplate" do
      expect(publication.meta_description).to match publication_name
    end
    it "leaves the tagline blank" do
      expect(publication.tagline).to be_nil
    end
    it "actually persists the publication" do
      expect(publication).to eq Publication.first
    end
  end

end
