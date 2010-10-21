class PacketsController < InheritedResources::Base
  actions :create, :destroy

  def create
    @old_packet = params[:packet]
    @composition = @old_packet ? Packet.find(@old_packet).composition : Composition.find(params[:composition])
    @meeting = Meeting.find params[:meeting]
    @packet = Packet.new(:meeting => @meeting, :composition => @composition)
    if @packet.valid?
      @packet.save
    else
      render :debug
    end
  end

  def destroy
    @packet = Packet.find params[:id]
    @packet.destroy
  end

end
