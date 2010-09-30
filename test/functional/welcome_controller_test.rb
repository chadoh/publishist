require 'test_helper'

class WelcomeControllerTest < ActionController::TestCase
  def setup
    @chad = Person.create(
      :first_name => "Chad",
      :email => "chad.ostrowski@gmail.com"
    )
    Person.stubs(:editor).returns(@chad)
    Person.stubs(:coeditor).returns(@chad)
  end

  context "index action" do
    should "render index template" do
      get :index
      assert_template 'index'
    end
  end
end
