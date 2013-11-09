require_relative "../../app/services/homepage"

describe Homepage do
  let(:publication) { double.as_null_object }
  let(:homepage) { Homepage.new(publication) }

  it "is instantiated with one arg, a publication object" do
    expect(Homepage.new(publication)).to be_kind_of Homepage
  end

  describe "hook_present?" do
    context "when a hook submission is successfully found" do
      it "returns true" do
        expect(homepage.hook_present?).to be_true
      end
    end

    context "when no hook submission can be found" do
      it "returns false" do
        Homepage.any_instance.stub(:submission_for).and_return(nil)
        expect(homepage.hook_present?).to be_false
      end
    end
  end
end
