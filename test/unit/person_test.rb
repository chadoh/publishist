require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  setup do
    @person = Factory(:person)
  end

  should_have_many :attendances
  should_have_many :meetings, :through => :attendances

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

  context "ranks: when making a new person" do
    should "not give people any rank" do
      @person2 = Factory(:person2)
      assert_equal @person2.ranks.count, 0
    end
  end
end
