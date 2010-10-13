class AttendancesController < InheritedResources::Base
  actions :all, :except => [:index, :show, :new, :edit]
  belongs_to :meeting

  def create
    if person = Person.find_or_create(params[:attendance][:person])
      params[:attendance][:person] = person
    else
      params[:attendance][:person_name] = params[:attendance].delete :person
    end
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
