require 'test_helper'

class AttendancesControllerTest < ActionController::TestCase

  def setup
    @meeting = Factory.create :meeting
    @person = Factory.create :person
    @attendance = Attendance.create :meeting_id => @meeting.id, :person_id => @person.id, :answer => "meh"
  end

  context "create" do
    should "accept an already-in-existence person formatted as 'anything <email@blah.com>'" do
      post :create, :meeting_id => @meeting.id, :attendance => {
        :person => "I often eat cucumber cheesecake! <#{@person.email}>",
        :answer => "Yes and no"
      }
      assert_redirected_to meeting_url @meeting
      assert_equal @person, assigns(:attendance).person
      assert_equal session[:flash], {:notice => "#{@person.first_name} was there"}
    end

    should "accept a new person, if formatted correctly, and make an account for them" do
      post :create, :meeting_id => @meeting.id, :attendance => {
        :person => "Monseiur Maggot <maggot@gov.fr>",
        :answer => "Clearly yes!"
      }
      assert_redirected_to meeting_url @meeting
      person = Person.find_by_email "maggot@gov.fr"
      assert_equal person, assigns(:attendance).person
      assert_equal session[:flash], {:notice => "#{person.first_name} was there"}
    end

    should "create an attendance with a static, unlinked 'person' field if formatted any other way" do
      post :create, :meeting_id => @meeting.id, :attendance => {
        :person => "One time visitor",
        :answer => "u ppl'r krasie"
      }
      assert_redirected_to meeting_url @meeting
      assert_equal session[:flash], {:notice => "One was there"}
    end
  end

  context "update" do
    should "return a useful flash notice" do
      put :update, :meeting_id => @meeting.id, :id => @attendance.id, :attendance => {
        :answer => "Claro kasey!"
      }
      assert_redirected_to meeting_url @meeting
      @attendance.reload
      assert_not_equal @attendance.answer, 'meh'
      assert_equal session[:flash], {:notice => "#{@person.first_name}'s answer was changed"}
    end
  end

  context "destroy" do
    should "return a useful flash notice" do
      delete :destroy, :meeting_id => @meeting.id, :id => @attendance.id
      assert_redirected_to meeting_url @meeting
      assert_equal session[:flash], {:notice => "#{@person.first_name} wasn't there, after all"}
    end
  end
end
