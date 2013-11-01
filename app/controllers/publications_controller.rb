require 'homepage'

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

    respond_to do |format|
      format.html
    end
  end

  def new
  end

  def edit
    @publication = Publication.find(params[:id])
  end

  def create
    publication = PublicationCreator.new(params).create_publication
    redirect_to root_url(subdomain: publication.subdomain)
  end

  def update
    @publication = Publication.find(params[:id])

    respond_to do |format|
      if @publication.update_attributes(params[:publication])
        format.html { redirect_to root_url(subdomain: @publication.subdomain) }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @publication = Publication.find(params[:id])
    @publication.destroy

    respond_to do |format|
      format.html { redirect_to publications_url(subdomain: @publication.subdomain) }
    end
  end
end
