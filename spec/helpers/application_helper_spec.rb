require 'spec_helper'

describe ApplicationHelper do
  before :each do
    helper.extend Haml
    helper.extend Haml::Helpers
    helper.send :init_haml_helpers
  end

  describe "#error_messages" do
    context "when the available `resource` has errors" do
      it "should return error messages for the resource" do
        sub = Submission.create
        helper.stub(:resource).and_return(sub)
        content = helper.error_messages
        content.should match(/div id='errorExplanation'/)
        content.should match(/li>\s*#{sub.errors.full_messages.first}/)
        content.should match(/li>\s*#{sub.errors.full_messages.last}/)
      end
    end

    context "when the available `resource` does not have errors" do
      it "returns nil" do
        sub = Submission.new :author_email => "who@me.net", :title => "smidgen"
        sub.should be_valid
        helper.stub(:resource).and_return(sub)
        helper.error_messages.should be_nil
      end
    end
  end

  describe "#pretty_date" do
    context "when the date happens in another year" do
      it "shows the year" do
        date = 1.year.ago
        helper.pretty_date(date).should match(/#{1.year.ago.year}/)
      end
    end
    context "when the date occurs in this calendar year" do
      it "doesn't show the year" do
        date = Date.today
        helper.pretty_date(date).should_not match(/#{1.year.ago.year}/)
      end
    end
  end

  describe "#timeframe" do
    it "returns a semanticly marked-up timeframe from the given dates" do
      result = helper.timeframe(1.year.ago, Date.today)
      result.should match "<span class='timeframe'>\n  <time datetime="
      result.should match "</time>\n   &ndash; \n  <time datetime="
    end
  end

  describe "#current_person_can_see_score_for? submission" do
    before do
      @sub = stub('Submission', :scored? => true)
      helper.stub(:submission).and_return(@sub)
    end

    context "(when the editor is viewing)" do
      before do
        helper.stub(:communicates?).and_return(true)
        helper.stub(:scores_or_is_author?).and_return(false)
      end

      it "returns false when viewing meetings#show" do
        helper.stub(:current_page?).and_return(false)
        helper.current_person_can_see_score_for?(@sub).should be_false
      end

      it "returns true when viewing magazine#highest_scores" do
        parameters = {:controller => 'magazines', :action => 'highest_scores'}
        helper.stub(:params).and_return(parameters)
        helper.current_person_can_see_score_for?(@sub).should be_true
      end
    end

    context "(when the coeditor is viewing)" do
      before do
        helper.stub(:communicates?).and_return false
        helper.stub(:scores_or_is_author?).and_return true
      end

      it "returns true when viewing meetings#show" do
        helper.stub(:current_page?).and_return(false)
        helper.current_person_can_see_score_for?(@sub).should be_true
      end

      it "returns true when viewing magazine#highest_scores" do
        parameters = {:controller => 'magazines', :action => 'highest_scores'}
        helper.stub(:params).and_return(parameters)
        helper.current_person_can_see_score_for?(@sub).should be_true
      end
    end
  end
end
