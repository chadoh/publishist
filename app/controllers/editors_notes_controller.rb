class EditorsNotesController < InheritedResources::Base
  actions :create, :update
  respond_to :html, except: :new
  respond_to :js, only: :new

  def new
    @page = Page.find params[:page_id]
    @editors_note = @page.editors_notes.new
  end

  def create
    create! do |wants|
      wants.html { redirect_to [@editors_note.page.magazine, @editors_note.page] }
    end
  end

  def update
    update! do |wants|
      wants.html { redirect_to [@editors_note.page.magazine, @editors_note.page] }
    end
  end

end
