class PacketsController < InheritedResources::Base
  actions :create, :destroy

  def create
    @old_packet = params[:packet] || false
    @composition = @old_packet ? Packet.find(@old_packet).composition : Composition.find(params[:composition])
    @meeting = Meeting.find params[:meeting]
    @packet = Packet.new(:meeting => @meeting, :composition => @composition)
    if @packet.valid?
      @packet.save
    else
      render :nothing => true
    end
  end

  def update_position
    @packet = Packet.find params[:id]
    @packet.insert_at params[:position]
    render :nothing => true
  end

  def destroy
    @packet = Packet.find params[:id]
    @packet.destroy
  end

end
