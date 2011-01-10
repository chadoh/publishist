require 'spec_helper'

describe MeetingsController do
  let(:meeting) { Factory.create :meeting }
  let(:person) { Factory.create :person }

  before do
    sign_in person
  end

  describe "GET scores" do
    it "should be successful" do
      get 'scores', :id => meeting.id
      response.should be_success
    end
  end
end
