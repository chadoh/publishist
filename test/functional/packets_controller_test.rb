require 'test_helper'

class PacketsControllerTest < ActionController::TestCase

  def setup
    @m = Factory.create :meeting
    @c = Factory.create :poetry_submission
    @p = Factory.create :packet2
  end

  context "#create_update_or_destroy" do
    should "route to the create action if a composition is dropped on a meeting" do
      xhr :post, :create_update_or_destroy, {
        :the_thing => "composition_#{@c.id}",
        :coming_from => "unscheduled",
        :going_to => "meeting_#{@m.id}" }
      assert_template :create
    end

    should "route to the destroy action if a packet is dropped on 'unscheduled'" do
      xhr :post, :create_update_or_destroy, {
        :the_thing => "packet_#{@p.id}",
        :coming_from => "meeting_#{@m.id}",
        :going_to => "unscheduled" }
      assert_template :destroy
    end
  end

  #context "#create" do
    #setup do
      #post :create, :packet => {
        #:meeting_id => @m.id,
        #:composition_id => @c.id }
    #end

    #should "not render any action" do
      #assert_template nil
    #end

    #should "assign a position" do
      #assert_equal 1, assigns(:packet).position
    #end

  #end

  context "#update" do
  end

  context "#destroy" do
  end
                
end
