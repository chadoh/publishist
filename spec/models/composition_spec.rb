require 'spec_helper'

describe Composition do
  before(:each) do
    @person = Factory.create :person
  end

  it {
    should have_many(:packets).dependent(:destroy)
    should have_many(:meetings).through(:packets)
  }

  describe "#author" do
    context "when there is an associated author" do
      before(:each) do
        @compo = Composition.create(
          :title  => ';-)',
          :body   => 'he winks and smiles <br><br> both',
          :author => @person)
      end

      it "returns the associated author's name" do
        @compo.author.should == @person.name
      end

      it "returns a person object if passed 'true'" do
        @compo.author(true).should == @person
      end
    end

    context "when there is no associated author" do
      before(:each) do
        @compo = Composition.create :title => ';-)',
          :body => 'he winks and smiles <br><br> both',
          :author_email => 'me@you.com',
          :author_name => @person
      end

      it "returns the author_name field" do
        @compo.author.should == @person
      end

      it "returns nil if passed 'true'" do
        @compo.author(true).should == nil
      end
    end
  end
end
