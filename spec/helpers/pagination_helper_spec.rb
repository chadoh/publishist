require 'spec_helper'

describe PaginationHelper do
  before :each do
    helper.extend Haml
    helper.extend Haml::Helpers
    helper.send :init_haml_helpers
  end

  describe "#pages_for(magazine, current_page)" do
    before :all do
      @magazine = Magazine.create(
        accepts_submissions_from:  6.months.ago,
        accepts_submissions_until: Date.yesterday,
        nickname: 								 'Fruit Blots'
      )
      @magazine.publish []
    end
		before :each do
      helper.stub(:editor?).and_return(true)
      @pagination = helper.pages_for @magazine, @magazine.pages.first
		end

		subject { @pagination }
    it { should match %r{^<nav class=('|")pagination\1>} }
		it { should match %r{<ol class=('|")pages\1>} }
		it { should match %r{<li class=('|")page\1 id=\1page_\d\1><a href="/magazines/fruit-blots/toc">ToC</a></li>} }

    context "when an editor is viewing" do
      it "displays '+' signs so that new pages can be added at the beginning or end" do
        @pagination.should match %r{<form}
      end

      it "makes the current_page's title contenteditable=true" do
        @pagination.should match %r{<li class=('|")current page\1 contenteditable=\1true\1 id=\1page_\d\1>Cover</li>}
      end
    end
  end

end
