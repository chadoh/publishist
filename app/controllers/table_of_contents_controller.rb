class TableOfContentsController < ActionController::Base
  respond_to :html

  def create
    @page = Page.find params[:page_id]
    @table_of_contents = @page.table_of_contents = TableOfContents.create
    respond_with(@table_of_contents) do |wants|
      wants.html { redirect_to [@table_of_contents.page.issue, @table_of_contents.page] }
    end
  end

  def destroy
    @table_of_contents = TableOfContents.find params[:id]
    @table_of_contents.destroy
    respond_with(@table_of_contents) do |wants|
      wants.html { redirect_to [@table_of_contents.page.issue, @table_of_contents.page] }
    end
  end
end
