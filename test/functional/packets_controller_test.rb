require 'test_helper'

class PacketsControllerTest < ActionController::TestCase

  def setup
    @m = Factory.create :meeting
    @c = Factory.create :poetry_submission
  end

  context "#create" do
    setup do
      post :create, :packet => {
        :meeting_id => @m.id,
        :composition_id => @c.id }
    end

    should "not render any action" do
      assert_template nil
    end

    should "assign a position" do
      assert_equal 1, assigns(:packet).position
    end

  end

  context "#update" do
  end

  context "#destroy" do
  end
                
end
