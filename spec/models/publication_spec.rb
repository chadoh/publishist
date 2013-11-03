require 'spec_helper'

describe Publication do
  let(:publication) { Factory.build(:publication) }
  it {
    should have_many(:magazines).dependent(:destroy)
    should have_many(:submissions).dependent(:destroy)
    should have_many(:people)
    should have_one(:publication_detail).dependent(:destroy)
    should have_many(:meetings).through(:magazines)
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

  describe "#editor" do
    let(:publication) { Factory.create :publication }
    let(:ability) { Factory :ability, key: "communicates" }
    let(:mag1) { publication.magazines.create title: 'first', accepts_submissions_from: 1.week.ago }
    let(:mag2) { publication.magazines.create title: 'second' }
    let(:pos1) { mag1.positions.create name:  'Editor', abilities: [ability] }
    let(:pos2) { mag2.positions.create name:  'Editor', abilities: [ability] }
    let(:per1) { Person  .create name:  'sir roderick', email: 'roderick@example.com', primary_publication: publication }
    let(:per2) { Person  .create name:  'ser roderick', email: 'serroderick@example.com', primary_publication: publication }
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
      it "returns the first person in the publication" do
        mag1; mag2; per1 # instantiate
        expect(publication.editor).to eq per1
      end
    end
    context "when there are no communicators and, somehow, no people!" do
      it "gracefully returns an OpenStruct that has an email method" do
        mag1; mag2 # instantiate
        expect(publication.editor).to be_kind_of(OpenStruct)
        expect(publication.editor.email).to match "@publishist.com"
      end
    end
  end

  describe "#current_magazine" do
    before { publication.save }
    [ [Time.zone.now - 1.day, Time.zone.now + 1.day],
      [Time.zone.now.to_date, Time.zone.now + 3.days],
      [Time.zone.now - 3.days, Time.zone.now.end_of_day]
    ].each do |range|
      it "returns the magazine in #{range}" do
        mag1 = publication.magazines.create :accepts_submissions_from => range.first,
                                                 :accepts_submissions_until => range.last
        mag2 = publication.magazines.create
        expect(publication.current_magazine).to eq(mag1)
      end
    end
    it "returns the latest one, even if it's no longer accepting submissions" do
      mag  = publication.magazines.create(
        accepts_submissions_from:  6.months.ago,
        accepts_submissions_until: Time.zone.now - 1.day
      )
      expect(publication.current_magazine).to eq(mag)
      expect(publication.magazines.count).to eq(1)
    end
  end

  describe "#current_magazine!" do
    before { publication.save }
    let!(:old) { publication.magazines.create(
        accepts_submissions_from:  6.months.ago,
        accepts_submissions_until: Date.yesterday
    )}
    let(:new) { publication.current_magazine! }

    it "creates a new magazine if the latest one is no longer accepting submissions" do
      expect(new).not_to eq(old)
      publication.magazines.count.should be 2
    end
  end

end
