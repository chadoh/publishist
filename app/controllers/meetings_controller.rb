class MeetingsController < InheritedResources::Base
  before_filter :authenticate_person!, :only => [:index, :show]
  before_filter :editors_only, :except => [:index, :show]
  before_filter :attendance, :only => :show

  def show
    @attendance = resource.attendances.select {|a| a.person == current_person }.first
    if @attendance
      @show_score = true 
    else
      @show_score = false
    end
    show!
  end

protected

  def attendance
    @attendance = Attendance.new
  end

  def resource
    @meeting = Meeting.includes(:attendances).find(params[:id])
  end
end
