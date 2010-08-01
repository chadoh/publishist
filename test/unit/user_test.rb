require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = Factory.build(:user)
  end

  subject { Factory(:user) }
  should validate_presence_of :name
  should validate_uniqueness_of :name
end
