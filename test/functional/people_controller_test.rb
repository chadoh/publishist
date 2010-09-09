require 'test_helper'

class PeopleControllerTest < ActionController::TestCase

  def setup
    sign_in_user
  end

  context "update action" do
    should "display person's profile page when successful" do
      Person.any_instance.stubs(:valid?).returns(true)
      put :update, :id => @user.id, :person => { }
      assert_redirected_to :action => 'show'
      assert_equal session[:flash][:notice], "Your account has been updated"
    end

    should "display edit template again when unsuccessful" do
      put :update, :id => @user.id, :person => { :password => 'secret', :password_confirmation => 'terces' }
      assert_template 'edit'
    end
  end

  context "Promoting" do
    setup do
      @person = Factory.create(:person2)
    end

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
