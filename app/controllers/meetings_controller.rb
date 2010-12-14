class MeetingsController < InheritedResources::Base
  before_filter :authenticate_person!, :only => [:index, :show]
  before_filter :editors_only, :except => [:index, :show]
  before_filter :attendance, :only => :show

protected

  def attendance
    @attendance = Attendance.new
  end

  def collection
    @meetings = Meeting.order("created_at DESC")
  end

  def resource
    @meeting = Meeting.includes(:attendances).find(params[:id])
  end
end
