class EditorsNotesController < InheritedResources::Base
  respond_to :html, except: [:new, :edit]
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

  def edit
    @editors_note = EditorsNote.find params[:id]
    respond_with(@editors_note) do |wants|
      wants.js
    end
  end
  def update
    update! do |wants|
      wants.html { redirect_to [@editors_note.page.magazine, @editors_note.page] }
    end
  end

  def destroy
    @editors_note = EditorsNote.find params[:id]
    @editors_note.destroy
    respond_with(@editors_note) do |wants|
      wants.html { redirect_to [@editors_note.page.magazine, @editors_note.page] }
    end
  end

end
