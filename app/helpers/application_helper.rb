module ApplicationHelper
  def pluralize_phrase(number, singular_phrase, plural_phrase)
    return singular_phrase if number == 1
    return plural_phrase if number > 1
  end
  def email_image(composition)
    image_tag('/images/email.png', :title => "Send an email to #{composition.author_first}", :alt => "Send email to #{composition.author}")
  end

  def show_composition(compo, title_options = {}, body_options = {}, author_options = {})
    title_options[:class] = "composition title"
    body_options[:class] = "composition body"
    author_options[:class] = "composition author"

    content = content_tag(:h2, title_options) do
      sanitize compo.title
    end
    content << content_tag(:div, body_options) do
      body = compo.photo? ? "#{image_tag(compo.photo.url(:medium))}<br>" : ''
      body += compo.body.blank? ? '' : compo.body
      sanitize body
    end
    content << content_tag(:p, author_options) do
      compo.author
    end
  end

  def pretty_date(date)
    if date < Time.now.years_ago(1)
      date.strftime("%d %b %Y")
    else
      date.strftime("%d %b")
    end
  end
end
