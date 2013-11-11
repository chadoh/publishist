require 'spec_helper'

describe Publication do
  let(:publication) { Factory.build(:publication) }
  it {
    should have_many(:issues).dependent(:destroy)
    should have_many(:submissions).dependent(:destroy)
    should have_many(:people)
    should have_one(:publication_detail).dependent(:destroy)
    should have_many(:meetings).through(:issues)
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
    let(:mag1) { publication.issues.create title: 'first', accepts_submissions_from: 1.week.ago }
    let(:mag2) { publication.issues.create title: 'second' }
    let(:pos1) { mag1.positions.create name:  'Editor', abilities: [ability] }
    let(:pos2) { mag2.positions.create name:  'Editor', abilities: [ability] }
    let(:per1) { Person  .create name:  'sir roderick', email: 'roderick@example.com', primary_publication: publication }
    let(:per2) { Person  .create name:  'ser roderick', email: 'serroderick@example.com', primary_publication: publication }
    context "when the publication's most recent issue has at least one person with the 'communicates' ability" do
      it "returns that person" do
        pos1.people << per1
        pos2.people << per2
        expect(publication.editor).to eq(per2)
      end
    end
    context "when the publication's most recent issue doesn't have such a person, but the next one does" do
      it "returns the person from the second issue" do
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

  describe "#current_issue" do
    before { publication.save }
    [ [Time.zone.now - 1.day, Time.zone.now + 1.day],
      [Time.zone.now.to_date, Time.zone.now + 3.days],
      [Time.zone.now - 3.days, Time.zone.now.end_of_day]
    ].each do |range|
      it "returns the issue in #{range}" do
        mag1 = publication.issues.create :accepts_submissions_from => range.first,
                                                 :accepts_submissions_until => range.last
        mag2 = publication.issues.create
        expect(publication.current_issue).to eq(mag1)
      end
    end
    it "returns the latest one, even if it's no longer accepting submissions" do
      issue  = publication.issues.create(
        accepts_submissions_from:  6.months.ago,
        accepts_submissions_until: Time.zone.now - 1.day
      )
      expect(publication.current_issue).to eq(issue)
      expect(publication.issues.count).to eq(1)
    end
  end

  describe "#current_issue!" do
    before { publication.save }
    let!(:old) { publication.issues.create(
        accepts_submissions_from:  6.months.ago,
        accepts_submissions_until: Date.yesterday
    )}
    let(:new) { publication.current_issue! }

    it "creates a new issue if the latest one is no longer accepting submissions" do
      expect(new).not_to eq(old)
      publication.issues.count.should be 2
    end
  end

end
