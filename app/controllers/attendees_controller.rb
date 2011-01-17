class AttendeesController < InheritedResources::Base
  actions :create, :destroy
  belongs_to :meeting

  def create
    if person = Person.find_or_create(params[:attendee][:person])
      params[:attendee][:person] = person
    else
      params[:attendee][:person_name] = params[:attendee].delete :person
    end
    create! do |format|
      flash[:notice] = "#{resource.first_name} was there"
      format.html { redirect_to parent_url }
    end
  end

  def destroy
    destroy!(:notice => "#{resource.first_name} wasn't there, after all") { parent_url }
  end
end
