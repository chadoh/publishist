require 'test_helper'

class CompositionsControllerTest < ActionController::TestCase

  context "#index" do
    setup do
      rank = Factory.create :current_editor
      @p = rank.person
      @m = Factory.create :meeting
      sign_in_user @p
      get :index
    end

    should "have a section for unscheduled compositions" do
      assert_select "section#unscheduled"
    end

    should "have sections for each meeting" do
      assert_select "section#meeting_#{@m.id}"
    end
  end

  context "#create" do
    context "when not signed in" do
      should "redirect to the root url" do
        post :create, :composition => {
          :title => 'this',
          :body => 'dancing starlight',
          :author_name => "Randy Tull",
          :author_email => "randy@tull.net" }
        assert_redirected_to root_url
      end
    end

    context "when signed in but not the editor" do
      should "redirect to one's profile page" do
        @rank = Factory.create :current_coeditor
        @person = @rank.person
        sign_in_user(@person)

        post :create, :composition => {
          :title => 'this',
          :body => 'complacent moonlight',
          :author_id => @user.id }
        assert_redirected_to person_url(@person)
      end
    end

    context "when the editor is signed in" do
      should "redirect the compositions index" do
        @rank = Factory.create :current_editor
        @person = @rank.person
        sign_in_user(@person)

        @other_person = Factory.create :person2

        post :create, :composition => {
          :title => 'this',
          :body => 'intentional sunlight',
          :author => "#{@other_person.name} <#{@other_person.email}>" }
        assert_redirected_to compositions_url
      end
    end
  end

end
