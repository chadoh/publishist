require 'test_helper'

class PacketsControllerTest < ActionController::TestCase

  def setup
    @m = Factory.create :meeting
    @c = Factory.create :poetry_submission
    @p = Factory.create :packet2
  end

  context "#create" do
    should "work when sent a composition" do
      xhr :post, :create, {
        :meeting => @m.id,
        :composition => @c.id }
      assert_template :create
    end

    should "work when sent a packet instead of a composition" do
      @m2 = Factory.create :meeting2
      xhr :post, :create, {
        :meeting => @m2.id,
        :packet => @p.id }
      assert_template :create
    end

  end

  context "#destroy" do
    setup do
      xhr :delete, :destroy, :id => @p.id
    end

    should "use the destroy.js.erb template" do
      assert_template :destroy
    end

    should "destroy the packet" do
      assert_equal 0, Packet.count
    end
  end
                
end
