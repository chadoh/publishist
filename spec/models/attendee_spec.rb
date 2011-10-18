require 'spec_helper'

describe Attendee do

  it {
    should belong_to :meeting
    should belong_to :person
    should have_one  :magazine, through: :meeting
    should have_many :scores
    should validate_presence_of :meeting_id
  }

  before do
    @m = Factory.create :meeting
    @p = Factory.create :person
    @a = @m.attendees.new
  end

  it "validates presence of either person_id or person_name" do
    @a.should_not be_valid

    @a.person_name = "Scourges Truffle"
    @a.should be_valid

    @a.person_name = nil
    @a.person = @p
    @a.should be_valid
  end

  describe "#name_and_email" do
    it "returns the attendee's name & email as 'first last, email@ddress' if associated with a person" do
      @a.person = @p
      @a.name_and_email.should == "#{@p.full_name}, #{@p.email}"
    end
    it "returns the attendee#person_name if not associated with a person" do
      @a.person_name = "Goofy Spoofy"
      @a.name_and_email.should == "Goofy Spoofy"
    end
  end

  describe "#first_name" do
    it "returns the first name from person_name" do
      @a.person_name = "Macy Tiders"
      @a.first_name.should == "Macy"
    end

    it "returns person.first_name if there's an associated person" do
      @a.person = @p
      @a.first_name.should == @p.first_name
    end
  end

  it "puts the submitter into all positions that have the 'disappears' ability upon creation" do
    ab  = Ability.create key: 'disappears', description: "Submitters & attendees are automatically added to this group. It will disappear once the magazine is published."
    pos = Magazine.create.positions.create name: "The Folks", abilities: [ab]
    @a.person = @p
    @a.save
    @p.positions.should be_present
    @p.positions.first.should == pos
  end


end
