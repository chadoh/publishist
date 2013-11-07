jQuery ->
  toggles = $("[data-behavior=typsy-toggle]")
  tips    = $("[data-behavior=typsy-container]")
  toggles.click (e) ->
    tips.fadeToggle()
    e.preventDefault()
