require 'spec_helper'

describe Rank do

  before(:each) do
    @person = Factory(:person)
    @date = DateTime.parse("2006-08-16 12:12:23")
  end

  it { should belong_to :person }

  it "allows ranks in the range 0..3" do
    for good in 0..3
      rank = Rank.new(:person_id => @person, :rank_type => good, :rank_start => @date)
      rank.should be_valid
    end
  end
  
  it "does not allow ranks outside of 0..3" do
    for bad in [-1, 4]
      rank = Rank.new(:person_id => @person, :rank_type => bad, :rank_start => @date)
      rank.should_not be_valid
    end
  end

  it "allows multiple ranks for one person" do
    Rank.create(:person_id => @person.id, :rank_type => 1, :rank_start => @date)
    @person.ranks.count.should == 1

    @coeditor_rank = Rank.create(:person_id => @person.id, :rank_type => 2, :rank_start => @date)
    @person.ranks.count.should == 2

    @coeditor_rank.destroy
    Rank.create(:person_id => @person.id, :rank_type => 3, :rank_start => @date)
    @person.ranks.count.should == 2
  end

  it "ends person's current editorship if new one is made" do
    @person.ranks.count.should == 0

    Rank.create(:person_id => @person.id, :rank_type => 2, :rank_start => @date)
    @person.ranks.count.should == 1
    
    Rank.create(:person_id => @person.id, :rank_type => 3, :rank_start => (@date >> 12))
    persons_editorships = Rank.find(:all, :conditions => "(rank_type=2 or rank_type=3) and rank_end IS NULL and person_id=#{@person.id}")
    persons_editorships.count.should == 1
  end

  it "only allows one editorship of each kind at a time" do
    @person.ranks.count.should == 0

    @person2 = Factory(:person)
    @person3 = Factory(:person)
    Rank.create(:person_id => @person.id, :rank_type => 2, :rank_start => @date)
    Rank.create(:person_id => @person2.id, :rank_type => 3, :rank_start => @date >> 12)
    Rank.create(:person_id => @person3.id, :rank_type => 3, :rank_start => @date >> 24)
    Rank.all.count.should == 3
    Person.editors.count.should == 2

    Rank.create(:person_id => @person2.id, :rank_type => 2, :rank_start => @date >> 24)
    Rank.all.count.should == 4
    Person.editors.count.should == 2
  end
end
