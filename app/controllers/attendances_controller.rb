class AttendancesController < InheritedResources::Base
  actions :all, :except => [:index, :show, :new]
  belongs_to :meeting

  def create
    params[:attendance][:person] = Person.find_or_create params[:attendance][:person]
    params[:attendance].delete "meeting"
    create! do |format|
      flash[:notice] = "#{resource.person.first_name} was there"
      format.html { redirect_to parent_url }
    end
  end

  def update
    update!(:notice => "#{resource.person.first_name}'s answer was changed") { parent_url }
  end

  def destroy
    destroy!(:notice => "#{resource.person.first_name} wasn't there, after all") { parent_url }
  end
end
