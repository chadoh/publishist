require 'spec_helper'

describe PagesController do
  before :all do
    @mag = Magazine.create(
      accepts_submissions_from:  6.months.ago,
      accepts_submissions_until: Date.yesterday,
      nickname: 								 'Fruit Blots'
    )
    @mag.publish []
  end
  describe "routing" do
    it "routes a magazine's cover to /magazines/mag-slug/cover" do
      path = magazine_page_path(@mag, @mag.pages.first)
      path.should == '/magazines/fruit-blots/cover'
      # { get: path }.should route_to(
      #   controller: 'pages',
      #   action:     'show',
      #   id:         'cover'
      # )
    end

    it "routes page creation to /magazines/mag-slug/pages" do
      path = magazine_pages_path(@mag)
      path.should == '/magazines/fruit-blots/pages'
      # { post: path }.should route_to(
      #   controller: 'pages',
      #   action:     'create'
      # )
    end
  end
end
