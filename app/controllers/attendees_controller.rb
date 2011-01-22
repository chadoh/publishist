class AttendeesController < InheritedResources::Base
  actions :create, :edit, :update, :destroy
  belongs_to :meeting
  respond_to :html, :js

  def create
    params[:attendee] = set_person_param_from_string params[:attendee]

    create! do |wants|
      wants.html do
        flash[:notice] = "Hello, #{resource.first_name}."
        redirect_to parent_url
      end
      wants.js
    end
  end

  def update
    @meeting = Meeting.find params[:meeting_id]
    @attendee = @meeting.attendees.find params[:id]

    params[:attendee] = set_person_param_from_string params[:attendee] if params[:attendee][:person]

    respond_to do |wants|
      if @attendee.update_attributes(params[:attendee])
        wants.js { head :accepted }
        wants.html { redirect_to parent_url }
      else
        wants.js { head :not_acceptable }
        wants.html { render :edit }
      end
    end
  end

  def set_person_param_from_string attendee
    if person = Person.find_or_create(attendee[:person])
      attendee[:person] = person
    else
      attendee[:person_name] = attendee.delete :person
    end
    attendee
  end

  def destroy
    destroy! do |wants|
      wants.html { redirect_to parent_url }
      wants.js { render :nothing => true }
    end
  end
end
