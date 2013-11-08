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
      { "This page features one of your published works, randomly selected on each page load." => "key",
        "This is your home page. You can edit the content on it with the link at the bottom." => "info",
      }
    when "magazines#index"
      { "It looks like an issue's submission period is over, so you can review its highest-scored submissions." => "key",
        "Click 'Staff List' for any issue to fine-tune who can view submissions' authors, scores, and meetings for that issue." => "info",
      }
    when "magazines#highest_scores"
      { "These are the highest-scored submissions for this issue. You can uncheck some, if you don't want them published." => "info",
      }
    when "pages#show"
      { "This will not be publicly browsable until you click \"Let everyone who submitted know it's been published\"." => "key",
        "Use the inline controls in the pagination to add & remove pages." => "info",
        "You can click the right edge of a submission and drag to a new page (note: it will drop onto the page with the dotted outline, not necessarily the one you're moused over. :-/ )" => "info",
        "Click the big plus at the bottom left to add notes or special items to pages." => "info",
      }
    when "magazines#staff_list"
      { "This is your main command center. All of the permissions for the whole website are based on what's on these staff lists; controlled issue-by-issue." => "info",
        "Mouse over the little circular letters next to the name of each position to see what abilities people in that position have." => "info",
        "You don't have to name your positions this way. Each issue can have uniquely-named positions, and different permission structures. Click the pencil icons to see." => "info",
        "To keep everything from breaking, if someone has the \"orchestrates\" ability for an issue, they'll be able to edit the staff lists of adjacent issues." => "info"
      }
    when "meetings#index"
      { "Publishist encourages you to have regularly-scheduled, real-life meetings of your staff where you read submissions aloud, discuss, and score them." => "info",
        "You don't have to do that, but be aware that scores can only be entered from a meeting's page, so you'll have to at least pretend you have coordinated meetings." => "info",
        "Each meeting has a \"Question\". Answering a creative question makes roll call way more fun." => "info",
      }
    when "meetings#show"
      { "This is where you'll probably spend most of your time, if you have regular staff meetings." => "info",
        "Attendees listed at the bottom can enter their own scores for the submissions at the top. (Bring laptops to the meeting & do it there!)" => "info",
        "If attendees don't enter their own scores, then someone with the \"scores\" ability can for them (control permissions on the staff list page, accessed from the magazines list)." => "info",
        "Each attendee can also edit their own answer to the attendance question by mousing over & clicking their current answer." => "info",
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
