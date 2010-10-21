class PacketsController < InheritedResources::Base
  actions :create, :destroy

  def create
    @old_packet = params[:packet]
    @composition = params[:composition] ? Composition.find(params[:composition]) : Packet.find(params[:packet]).composition
    @meeting = Meeting.find params[:meeting]
    @packet = Packet.create :meeting => @meeting, :composition => @composition
  end

  def destroy
    @packet = Packet.find params[:id]
    @packet.destroy
  end

end
