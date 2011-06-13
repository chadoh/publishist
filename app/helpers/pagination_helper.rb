module PaginationHelper
  include Rails.application.routes.url_helpers

  def pages_for magazine, current_page
    capture_haml do
      haml_tag 'nav.pagination', :< do
        haml_tag 'ol.pages', :< do
          if editor?
            haml_concat render(partial: "pages/form", locals: { position: :beginning })
          end
          for page in magazine.pages
            if page == current_page && editor?
              haml_tag "li#page_#{page.id}.page", :<, { contenteditable: 'true', data: { model: "page", attribute: "title", path: magazine_page_path(magazine, page) } } do
                haml_concat link_to_unless page == current_page, page.title, magazine_page_path(magazine, page)
              end
            else
              haml_tag "li#page_#{page.id}.page", :< do
                haml_concat link_to_unless page == current_page, page.title, magazine_page_path(magazine, page)
              end
            end
          end
          if editor?
            haml_concat render(partial: "pages/form", locals: { position: :end })
          end
        end
      end
    end
  end
end
