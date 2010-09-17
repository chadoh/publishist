require 'test_helper'

class MeetingsControllerTest < ActionController::TestCase
  require 'application_helper'
  include ApplicationHelper

  def setup
    @meeting = Factory.create(:meeting)
  end

  context "editors" do
    should "be able to make and edit meetings" do
      rank = Factory.create(:current_editor)
      sign_in_user(rank.person)
      get :index
      assert_select "td", 4
      assert_select "a[href='#{new_meeting_path}']"
      sign_out_user

      Person.last.delete
      Rank.last.delete
      rank = Factory.create(:current_coeditor)
      assert_equal rank.person.highest_rank, rank
      sign_in_user(rank.person)
      get :index
      assert_select "td", 4
      assert_select "a[href='#{new_meeting_path}']"
    end
  end

  context "staff" do
    should "be able to see the page but not edit the meetings" do
      rank = Factory.create(:current_staff)
      sign_in_user rank.person
      get :index
      assert_select "td", 2
      assert_select "a[href='#{new_meeting_path}']", false
    end
  end

end
