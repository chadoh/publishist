require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  setup do
    @person = Factory(:person)
  end

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
    should "make them editor if there are no editors" do
      assert_equal Person.count, 1
      assert_equal Person.first, @person
      assert_equal @person.ranks.count, 1
      assert_equal @person.ranks.first.rank_type, 3
    end

    should "not give successive people any rank" do
      @person2 = Factory(:person2)
      assert_equal @person2.ranks.count, 0
    end
  end
end
