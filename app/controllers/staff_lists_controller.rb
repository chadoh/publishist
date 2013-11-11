class StaffListsController < ActionController::Base
  respond_to :html

  def create
    @page = Page.find params[:page_id]
    @staff_list = @page.staff_list = StaffList.create
    respond_with(@staff_list) do |wants|
      wants.html { redirect_to [@staff_list.page.issue, @staff_list.page] }
    end
  end

  def destroy
    @staff_list = StaffList.find params[:id]
    @staff_list.destroy
    respond_with(@staff_list) do |wants|
      wants.html { redirect_to [@staff_list.page.issue, @staff_list.page] }
    end
  end

end
