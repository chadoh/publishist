class PacketsController < InheritedResources::Base
  actions :create, :update, :destroy

  def create
    @meeting = Meeting.find params[:meeting].split('_').last
    @composition = Composition.find params[:composition].split('_').last
    @packet = Packet.create :meeting_id => @meeting.id, :composition_id => @composition.id
  end

end
