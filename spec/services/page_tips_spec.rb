require_relative "../../app/services/page_tips"

describe PageTips do
  let(:page) { "publications#show" }
  let(:person) { double("person", orchestrates?: false) }
  let(:include_conditional_tips) { false }
  let(:page_tips) { PageTips.new(page, person, include_conditional_tips) }

  it "is instantiated with three args, the symbolized name of the page, a person, and whether to include conditional tips" do
    expect(PageTips.new(:home, person, false)).to be_kind_of PageTips
  end

  describe "#tips" do
    context "when the person is nil (not signed in)" do
      let(:person) { nil }
      it "returns nil" do
        expect(page_tips.tips).to be_nil
      end
    end

    context "when the person doesn't have the orchestrates ability" do
      it "returns nil" do
        expect(page_tips.tips).to be_nil
      end
    end
    context "when the person has the orchestrates ability" do
      let(:person) { double("person", orchestrates?: true) }

      it "returns a hash" do
        expect(page_tips.tips).to be_kind_of Hash
      end

      context "when show_conditional_tips == false" do
        it "doesn't include tips with value of 'key'" do
          expect(page_tips.tips.values).not_to include "key"
        end
      end

      context "when show_conditional_tips == true" do
        let(:include_conditional_tips) { true }
        it "includes tips with value of 'key'" do
          expect(page_tips.tips.values).to include "key"
        end
      end

      context "when there are no tips for the provided page" do
        let(:page) { "notapage" }
        it "returns nil" do
          expect(page_tips.tips).to be_nil
        end
      end

    end
  end
end
