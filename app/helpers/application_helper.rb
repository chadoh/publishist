module ApplicationHelper
  def pluralize_phrase(number, singular_phrase, plural_phrase)
    return singular_phrase if number == 1
    return plural_phrase if number > 1
  end
  def email_image(composition)
    image_tag('/images/email.png', :title => "Send an email to #{composition.author_first}", :alt => "Send email to #{composition.author}")
  end

  def pretty_date(date)
    if date < Time.now.years_ago(1)
      date.strftime("%d %b %Y")
    else
      date.strftime("%d %b")
    end
  end
end
