class AttendeesController < InheritedResources::Base
  actions :create, :edit, :update, :destroy
  belongs_to :meeting

  respond_to :html, :except => :update_answer
  respond_to :js

  before_filter only: :create do |c|
    c.must_orchestrate :any
  end
  before_filter only: [:edit, :update, :destroy] do |c|
    c.must_orchestrate resource
  end

  def create
    params[:attendee] = set_person_param_from_string params[:attendee]

    create! do |wants|
      wants.html do
        flash[:notice] = "Hello, #{resource.first_name}."
        redirect_to parent_url(subdomain: @publication.subdomain)
      end
      wants.js
    end
  end

  def edit
    respond_to do |wants|
      wants.js
      wants.html
    end
  end

  def update
    if params[:attendee]
      params[:attendee] = set_person_param_from_string params[:attendee] if params[:attendee][:person]
    end

    update! do |success, failure|
      success.html { redirect_to parent_url }
      failure.html { render :edit }

      success.js
      failure.js { render :edit }
    end
  end

  def update_answer
    update! do |success, failure|
      success.js { head :accepted }
      failure.js { head :not_acceptable }
    end
  end

  def set_person_param_from_string attendee
    if person = Person.find_or_create(attendee[:person], primary_publication_id: @publication.id)
      attendee[:person] = person
    else
      attendee[:person_name] = attendee.delete :person
    end
    attendee
  end

  def destroy
    destroy! do |wants|
      wants.html { redirect_to parent_url }
      wants.js
    end
  end
end
