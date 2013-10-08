require 'spec_helper'

describe Publication do
  let(:publication) { Factory.build(:publication) }
  it {
    should have_many(:magazines).dependent(:destroy)
    should have_many(:submissions).dependent(:destroy)
    should have_one(:publication_detail).dependent(:destroy)
  }
  [:address,
   :latitude,
   :longitude,
   :about,
   :meetings_info,
  ].each do |attr|
    it "forwards #{attr} to its publication_details model" do
      expect(publication.public_send(attr)).not_to be_blank
    end
  end

  describe ".editor" do
    let(:publication) { Factory.create :publication }
    let(:ability) { Factory :ability, key: "communicates" }
    let(:mag1) { publication.magazines.create title: 'first', accepts_submissions_from: 1.week.ago }
    let(:mag2) { publication.magazines.create title: 'second' }
    let(:pos1) { mag1.positions.create name:  'Editor', abilities: [ability] }
    let(:pos2) { mag2.positions.create name:  'Editor', abilities: [ability] }
    let(:per1) { Person  .create name:  'sir roderick', email: 'roderick@example.com' }
    let(:per2) { Person  .create name:  'ser roderick', email: 'serroderick@example.com' }
    context "when the publication's most recent magazine has at least one person with the 'communicates' ability" do
      it "returns that person" do
        pos1.people << per1
        pos2.people << per2
        expect(publication.editor).to eq(per2)
      end
    end
    context "when the publication's most recent magazine doesn't have such a person, but the next one does" do
      it "returns the person from the second magazine" do
        pos1.people << per1
        pos2; per2 # instantiate
        expect(publication.editor).to eq(per1)
      end
    end
    context "when there are no communicators" do
      it "raises an error saying so" do
        expect{ publication.editor }.to raise_error(NoEditorForPublication)
      end
    end
  end

end
