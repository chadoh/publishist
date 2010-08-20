require 'test_helper'

class RankTest < ActiveSupport::TestCase

  def setup
    @person = Factory(:person)
    @person.ranks.first.destroy # don't want them to be made editor automatically, want to do it manually
    @date = DateTime.parse("2006-08-16 12:12:23")
  end

  context "adding new ranks" do
    should "only allow ranks in the range 0-4" do
      allowed = [0, 1, 2, 3]
      not_allowed = [-1, 4]

      allowed.each do |good|
        rank = Rank.new(:person_id => @person.id, :rank_type => good, :rank_start => @date)
        assert rank.valid?
      end

      not_allowed.each do |bad|
        rank = Rank.new(:person_id => @person.id, :rank_type => bad, :rank_start => @date)
        assert !rank.valid?
      end
    end

    should "allow multiple ranks for one person" do
      @staff_rank = Rank.new(:person_id => @person.id, :rank_type => 1, :rank_start => @date)
      assert @staff_rank.save
      assert_equal @person.ranks.count, 1

      @coeditor_rank = Rank.new(:person_id => @person.id, :rank_type => 2, :rank_start => @date)
      assert @coeditor_rank.save
      assert_equal @person.ranks.count, 2
      @coeditor_rank.destroy
      assert_equal @person.ranks.count, 1

      @editor_rank = Rank.new(:person_id => @person.id, :rank_type => 3, :rank_start => @date)
      assert @editor_rank.save
      assert_equal @person.ranks.count, 2
    end

    should "end person's current editorship if new one is made" do
      assert_equal @person.ranks.count, 0

      @coeditor_rank = Rank.new(:person_id => @person.id, :rank_type => 2, :rank_start => @date)
      assert @coeditor_rank.save
      assert_equal @person.ranks.count, 1
      
      @editor_rank = Rank.new(:person_id => @person.id, :rank_type => 3, :rank_start => (@date >> 12))
      assert @editor_rank.save
      persons_editorships = Rank.find(:all, :conditions => "(rank_type=2 or rank_type=3) and rank_end IS NULL and person_id=#{@person.id}")
      assert_equal persons_editorships.count, 1
    end

    should "only allow one editorship of each kind at a time" do
      assert_equal @person.ranks.count, 0

      @person2 = Factory(:person2)
      @person3 = Factory(:person3)
      @person2.ranks.first.destroy #don't want them to automatically be made editor, want to do it manually
      @coeditor_rank = Rank.new(:person_id => @person.id, :rank_type => 2, :rank_start => @date).save
      @editor_rank = Rank.new(:person_id => @person2.id, :rank_type => 3, :rank_start => @date >> 12).save
      @new_editor = Rank.new(:person_id => @person3.id, :rank_type => 3, :rank_start => @date >> 24).save
      assert_equal Rank.all.count, 3
      assert_equal Person.current_editors.count, 2

      @new_coeditor = Rank.new(:person_id => @person2.id, :rank_type => 2, :rank_start => @date >> 24).save
      assert_equal Rank.all.count, 4
      assert_equal Person.current_editors.count, 2
    end
  end
end
