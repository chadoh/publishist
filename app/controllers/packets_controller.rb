class PacketsController < InheritedResources::Base
  actions :create, :update, :destroy

  def create_update_or_destroy
    the_thing = params[:the_thing].split('_').first
    coming_from = params[:coming_from].split('_').first
    going_to = params[:going_to].split('_').first

    if the_thing == 'composition'
      @composition = Composition.find params[:the_thing].split('_').last
      @meeting = Meeting.find params[:going_to].split('_').last
      @packet = Packet.create :meeting_id => @meeting.id, :composition_id => @composition.id
      render :action => "create"
    elsif the_thing == 'packet' && going_to == 'unscheduled'
      @packet = Packet.find params[:the_thing].split('_').last
      @packet.destroy
      render :action => 'destroy'
    end
  end

end
