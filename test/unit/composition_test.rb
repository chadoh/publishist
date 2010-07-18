require 'test_helper'

class CompositionTest < ActiveSupport::TestCase
  def setup
    @composition = Factory.build(:composition)
  end

  should validate_presence_of :body

  should "add 'Anonymous' for author if field left blank" do
    compo = Composition.new(:body => "some text")
    compo.save
    assert_equal compo.author, "Anonymous"
  end

  should "add 'untitled' for title if field left blank" do
    compo = Composition.new(:body => "some text")
    compo.save
    assert_equal compo.title, "untitled"
  end

  #should "turn plain-text line breaks into <br>s" do
    #@composition.body = "This stuff\r\nand this stuff, too"
    #@composition.save
    #@composition.body.split('<br>').length
    #assert_equal @composition.body.split('<br>').length, 2
  #end
end
