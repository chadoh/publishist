require 'spec_helper'

describe SubmissionsController do
  describe "routing" do
    it '/submissions to Submissions#index' do
      path = submissions_path
      path.should == '/submissions'
      { :get => path }.should route_to(
        :controller => 'submissions',
        :action => 'index'
      )
    end
    it '/submit to Submission#new' do
      path = new_submission_path
      path.should == '/submit'
      { :get => path }.should route_to(
        :controller => 'submissions',
        :action => 'new'
      )
    end
    it '/:submission_id to Submission#show' do
      path = submission_path 'dandelion-plum'
      path.should == '/dandelion-plum'
      { :get => path }.should route_to(
        :controller => 'submissions',
        :action => 'show',
        :id => 'dandelion-plum'
      )
    end
    it '/:submission_id/edit to Submission#edit' do
      path = edit_submission_path 'dandelion-plum'
      path.should == '/dandelion-plum/edit'
      { :get => path }.should route_to(
        :controller => 'submissions',
        :action => 'edit',
        :id => 'dandelion-plum'
      )
    end
  end
end
