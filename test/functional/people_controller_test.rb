require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @person = Factory.create(:person)
  end

  context "Promoting" do
    should "make staff" do
      assert_equal Rank.count, 0
      post :make_staff, :id => @person.id
      assert_equal Rank.count, 1
      @person.reload
      assert_equal @person.highest_rank.rank_type, 1
    end

    should "make coeditor" do
      post :make_staff, :id => @person.id
      post :make_coeditor, :id => @person.id
      @person.reload
      assert_equal @person.highest_rank.rank_type, 2
      assert_equal @person.current_ranks.count, 2
    end

    should "make editor" do
      post :make_staff, :id => @person.id
      post :make_coeditor, :id => @person.id
      post :make_editor, :id => @person.id
      @person.reload
      assert_equal @person.highest_rank.rank_type, 3
      assert_equal @person.current_ranks.count, 2
    end
  end
end
