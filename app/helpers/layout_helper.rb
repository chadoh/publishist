# These helper methods can be called in your template to set variables to be used in the layout
# This module should be included in all views globally,
# to do so you may need to add this line to your ApplicationController
#   helper :layout
module LayoutHelper
  def title(page_heading, append_to_page_title = "")
    @content_for_title = strip_tags(page_heading.to_s)
    @content_for_title += append_to_page_title
    @content_for_title += " | #{@publication.try(:name) || 'Publishist'}"
    @content_for_page_heading = page_heading.to_s
    @article_id = page_heading.parameterize
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def javascript(*args)
    content_for(:javascript) { javascript_include_tag(*args) }
  end

  # Helper function to add class="selected" to the active tab
  def selected_tab_if(active_tab)
    (active_tab == @active_tab) ? 'selected' : 'not_selected'
  end

end
