class AttendeesController < InheritedResources::Base
  actions :create, :edit, :update, :destroy
  belongs_to :meeting

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
    params[:attendee] = set_person_param_from_string params[:attendee]

    update! do |wants|
      wants.html do
        flash[:notice] = "Attendance record for #{resource.first_name} was updated"
        redirect_to parent_url
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
