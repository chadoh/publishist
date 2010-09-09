require 'test_helper'

class CompositionTest < ActiveSupport::TestCase
  setup do
    @compo = Composition.new(:body => "some text", :author_email => "you@me.com")
    @compo.save
  end

  should "add 'Anonymous' for author if field left blank" do
    assert_equal @compo.author_name, "Anonymous"
  end

  should "require author_email to be filled out if user not signed in" do
    compo = Composition.new(:body => "some other text")
    assert !compo.valid?
    assert_equal compo.errors.keys.first, :author_email

    sign_in_user
    compo = Composition.new(:body => "some brand new thoughts", :author_id => @user.id)
    assert compo.valid?
  end

  should "add 'untitled' for title if field left blank" do
    assert_equal @compo.title, "untitled"
  end

  context "creating" do
    should "not allow both an association to a Person and the name &/or email fields to be filled out" do
      @user = Factory.create(:person)
      compo = Composition.new(:body => "some brand new thoughts", :author_id => @user.id, :author_email => "barn@cl.es")
      assert !compo.valid?
    end
  end
end
