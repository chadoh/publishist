require 'spec_helper'
require 'publication_creator'

describe PublicationCreator do
  let(:creator) { PublicationCreator.new }
  it "is instantiated with no args" do
    expect(creator).to be_kind_of PublicationCreator
  end

  it "responds to #editor_email" do
    expect(creator.editor_email).to be_nil
  end

  it "responds to #publication_name" do
    expect(creator.publication_name).to be_nil
  end
end
