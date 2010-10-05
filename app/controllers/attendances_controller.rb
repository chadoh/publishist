class AttendancesController < InheritedResources::Base
  actions :all, :except => [:index, :show, :new]
  belongs_to :meeting

  def create
    person_string = params[:attendance][:person]
    person = Person.find_or_create person_string
    if person
      params[:attendance][:person] = person
    else
      params[:attendance].delete :person
      params[:attendance][:person_name] = person_string
    end
    params[:attendance].delete :meeting
    create! do |format|
      flash[:notice] = "#{resource.first_name} was there"
      format.html { redirect_to parent_url }
    end
  end

  def update
    update!(:notice => "#{resource.first_name}'s answer was changed") { parent_url }
  end

  def destroy
    destroy!(:notice => "#{resource.first_name} wasn't there, after all") { parent_url }
  end
end
