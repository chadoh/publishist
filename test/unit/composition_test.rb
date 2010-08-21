require 'test_helper'

class CompositionTest < ActiveSupport::TestCase
  should validate_presence_of :body

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
  end

  should "add 'untitled' for title if field left blank" do
    assert_equal @compo.title, "untitled"
  end
end
