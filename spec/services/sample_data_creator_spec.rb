require 'spec_helper'

describe SampleDataCreator do
  it "is instantiated with two arguments, a publication and an editor" do
    expect(SampleDataCreator.new publication: "foo", editor: "bar").to be_kind_of SampleDataCreator
  end

  describe "#seed_data" do
    let(:publication) { Factory.create :publication }
    let(:editor) { Factory.create :person, primary_publication: publication }
    let(:creator) { SampleDataCreator.new publication: publication, editor: editor }
    before { creator.seed_data }

    it "creates all of the expected data" do
      # two magazines; one old, one current
      mags = Magazine.all.reverse
      expect( mags[0].published_on.to_date ).to eq Time.zone.now.to_date
      expect( mags[0].accepts_submissions_until.to_date ).to eq (Time.zone.now - 6.months).to_date
      expect( mags[1].accepts_submissions_until.to_date ).to eq (Time.zone.now - 2.weeks).to_date
      expect( mags[2].accepts_submissions_from ).to  be < Time.zone.now
      expect( mags[2].accepts_submissions_until ).to be > Time.zone.now

      # editor is actually editor for all
      positions = %w(Editor Coeditor Staff)
      expect( mags[0].positions.map(&:name) ).to eq positions
      expect( mags[1].positions.map(&:name) ).to eq positions
      expect( mags[2].positions.map(&:name) ).to eq positions
      expect( editor.positions ).to eq Position.where(name: "Editor")

      # abilities for the positions
      expect( Position.all.map(&:abilities).map(&:count).uniq ).to eq [3, 2, 1]

      # submissions
      expect( mags[0].submissions.count ).to eq 4
      expect( mags[1].submissions.count ).to eq 4
      expect( mags[2].submissions.count ).to eq 4

      # editor's submissions
      states = %i(published rejected submitted)
      expect( editor.submissions.map(&:state) ).to eq states

      # meetings
      expect( mags[0].meetings.count ).to eq 1
      expect( mags[0].meetings.first.attendees.map(&:person) ).to include editor
      expect( mags[0].meetings.first.attendees.count ).to eq 13
      expect( mags[1].meetings.count ).to eq 1
      expect( mags[1].meetings.first.attendees.map(&:person) ).to include editor
      expect( mags[1].meetings.first.attendees.count ).to eq 13
      expect( mags[2].meetings.count ).to eq 2
      expect( mags[2].meetings.first.datetime ).to be > Time.zone.now
      expect( mags[2].meetings.last.datetime ).to be > Time.zone.now
    end
  end
end
