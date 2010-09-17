class MeetingsController < InheritedResources::Base
  before_filter :staff_only
end
