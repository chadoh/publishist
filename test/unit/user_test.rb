require 'test_helper'

class UserTest < ActiveSupport::TestCase
  subject { Factory(:user) }
  should validate_presence_of :first_name
  should validate_presence_of :email
  should validate_uniqueness_of :email

  context "password" do
    setup do
      @new_user = User.new(:email => "snuffles@mcguffles.com")
    end

    should "require that a password is set" do
      assert !@new_user.valid?
      assert_equal @new_user.errors[:password][0], "Missing password"
    end

    should "require a password of at least six characters" do
      @new_user.password = "verey"
      assert !@new_user.valid?
    end
  end

  context "names" do
    should "return 'first_name last_name' when calling method 'name'" do
      @user = Factory.build(:user)
      assert_equal @user.name, "#{@user.first_name} #{@user.last_name}"
    end
  end
end
