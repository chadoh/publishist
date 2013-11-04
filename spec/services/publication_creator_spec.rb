require 'spec_helper'

describe PublicationCreator do
  let(:publication_name) { "Fancy Prance" }
  let(:editor_email) { "hello@there.you" }
  let(:creator) { PublicationCreator.new(publication_name: publication_name, editor_email: editor_email) }
  let(:publication) { creator.create_publication }
  let(:editor) { creator.create_editor }

  it "is instantiated with a hash" do
    expect(creator).to be_kind_of PublicationCreator
  end

  describe "#create_publication" do
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
    it "sets about to some happy boilerplate" do
      expect(publication.about).to match publication_name
    end
    it "leaves the tagline blank" do
      expect(publication.tagline).to be_nil
    end
    it "actually persists the publication" do
      expect(publication).to eq Publication.first
    end
  end

  describe "#create_editor" do
    it "returns the person that it creates" do
      expect(editor).to be_kind_of Person
    end
    it "assigns the editor the email address passed in" do
      expect(editor.email).to eq editor_email
    end
    it "does not give the editor a name" do
      expect(editor.first_name).to be_nil
      expect(editor.last_name).to be_nil
      expect(editor.middle_name).to be_nil
    end
    it "sets the editor's primary_publication to the publication it created" do
      Person.any_instance.unstub(:primary_publication)
      expect(editor.primary_publication).to eq publication
    end
    it "actually persists the editor" do
      expect(editor).to eq Person.first
    end
  end

end
