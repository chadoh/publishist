class AttendeesController < InheritedResources::Base
  actions :create, :destroy
  belongs_to :meeting

  def create
    if person = Person.find_or_create(params[:attendee][:person])
      params[:attendee][:person] = person
    else
      params[:attendee][:person_name] = params[:attendee].delete :person
    end

    create! do |wants|
      wants.html { redirect_to parent_url }
      wants.js
    end
  end

  def destroy
    destroy! do |wants|
      wants.html { redirect_to parent_url }
      wants.js
    end
  end
end
