jQuery ->
  toggles = "[data-behavior=typsy-toggle]"
  tips    = "[data-behavior=typsy-container]"
  user    = $(tips).data("user")
  $(document).on "click", toggles, (e) ->
    $(tips).fadeToggle()
    e.preventDefault()
  $(document).on "click", "#{tips} input:checkbox", ->
    $.post("/people/#{user}/toggle_default_tips")
