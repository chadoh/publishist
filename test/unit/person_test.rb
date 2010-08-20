require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  context "names" do
    should "require first_name to be set" do
      @person = Person.new( :first_name => "Thad",
        :email                 => "th@d.com",
        :password              => "secret",
        :password_confirmation => "secret"
      )
      assert @person.valid?
    end
  end
end
