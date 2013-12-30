class PublicationsController < ApplicationController
  before_filter :except => [:show, :new, :create] do |c|
    c.must_orchestrate @publication
  end

  respond_to :html
  layout 'application', only: [:show, :edit]

  skip_before_filter :find_publication, only: [:show, :new, :create]

  def show
    @publication = current_publication
    @homepage = Homepage.new(@publication)
    @show_conditional_tips = !!@homepage.hook_present?
  end

  def new
  end

  def edit
    @publication = Publication.find(params[:id])
  end

  def create
    creator = PublicationCreator.new(params)
    publication = creator.create_publication
    editor = creator.create_editor
    SampleDataCreator.new(publication: publication, editor: editor).seed_data
    sign_in editor
    redirect_to root_url(subdomain: publication.subdomain),
      notice: "Welcome! We're seeding some sample data so you have something to
      look at. In the meantime, you've got some new email from us. :-)"
  end

  def update
    @publication = Publication.find(params[:id])

    respond_to do |format|
      if @publication.update_attributes(params[:publication])
        format.html { redirect_to root_url }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @publication = Publication.find(params[:id])
    @publication.destroy

    respond_to do |format|
      format.html { redirect_to publications_url }
    end
  end
end
