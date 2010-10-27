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

    should "render nothing if creation fails" do
      xhr :post, :create, {
       :meeting => @p.meeting,
       :composition => @p.composition }
      assert_template nil
    end

  end

  context "#update_position" do
    setup do
      @p2 = Packet.create :meeting => @p.meeting,
        :composition => Factory.create(:anonymous_poetry_submission)
      xhr :put, :update_position, {
        :id => @p.id,
        :position => 2 }
      @p.reload
    end

    should "render nothing" do
      assert_template nil
    end

    should "change the position for the identified packet and update the rest to match" do
      assert_equal @p.position, 2
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
