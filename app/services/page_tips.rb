class PageTips
  def initialize(page, person, include_conditional_tips)
    @page = page
    @person = person
    @include_conditional_tips = include_conditional_tips
  end

  def tips
    return nil unless @person && @person.orchestrates?

    tips = case @page
    when "publications#show"
      { "This is your home page. You can edit the content on it with the link at the bottom." => "info",
        "This page features one of your published works, randomly selected on each page load." => "key",
      }
    when "magazines#index"
      { "Click 'Staff List' for any issue to fine-tune who can view submissions' authors, scores, and meetings for that issue." => "info",
        "It looks like an issue's submission period is over, so you can review its highest-scored submissions." => "key"
      }
    end
    tips = remove_conditional(tips) unless @include_conditional_tips
    tips
  end

  private

  def remove_conditional(tips)
    tips and tips.reject { |key, value| value == "key" }
  end
end
