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
end
