module PaginationHelper
  extend ActiveSupport::Memoizable
  include Rails.application.routes.url_helpers

  def pages_for magazine, current_page
    capture_haml do
      haml_tag 'nav.pagination', :< do
        haml_tag 'ol.pages', :< do
          if editor?
            haml_concat render(partial: "pages/form", locals: { position: :beginning })
          end
          for page in magazine.pages
            haml_tag "li#page_#{page.id}.page", :<, { class: page == current_page && 'current', contenteditable: page == current_page && editor? && 'true' } do
              haml_concat link_to_unless page == current_page, page.title, magazine_page_path(magazine, page)
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
