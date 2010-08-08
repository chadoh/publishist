require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should "be valid" do
    assert Person.new.valid?
  end
end
