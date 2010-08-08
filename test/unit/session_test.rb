require 'test_helper'

class SessionTest < ActiveSupport::TestCase
  should "be valid" do
    assert Session.new.valid?
  end
end
