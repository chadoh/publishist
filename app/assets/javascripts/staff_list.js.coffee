$('a.toggle-adding-role').on 'click', (e) ->
  e.preventDefault()
  $(this).closest('footer').toggleClass('add-role')

$('form.new_role input.string').on 'focusin', ->
  $(this).autocomplete("/people/auto_complete_for_person_first_name_middle_name_last_name_email")

$('form.new_role input.string').on 'keyup', (e) ->
  if e.keyCode is 27
    $(this).closest('form').find('a.toggle-adding-role').click()

$('form.new_role input.string').blur().focus()
