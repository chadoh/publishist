class MeetingsController < InheritedResources::Base
  before_filter :members_only
  before_filter :attendance, :only => :show

protected

  def attendance
    @attendance = Attendance.new
  end

  def resource
    @meeting = Meeting.includes(:attendances).find(params[:id])
  end
end
