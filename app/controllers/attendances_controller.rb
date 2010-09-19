class AttendancesController < InheritedResources::Base
  actions :all, :except => [:index, :show, :new]
  belongs_to :meeting
  belongs_to :person
end
