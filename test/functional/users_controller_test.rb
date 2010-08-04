require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @input_attributes = {
      :first_name            => "phyllis",
      :email                 => "ph@dm.c",
      :password              => "private",
      :password_confirmation => "private"
    }
    @user = Factory.create(:user)
  end

  should "create user" do
    assert_difference('User.count') do
      post :create, :user => @input_attributes
    end

    assert_redirected_to users_path
  end

  should "update user" do
    put :update, :id => @user.to_param, :user => @input_attributes
    assert_redirected_to users_path
  end
end
