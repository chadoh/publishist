jQuery ->
  $('a.toggle-adding-role').on 'click', (e) ->
    e.preventDefault()
    $(this).closest('footer').toggleClass('add-role')

  $('input[name="role[person]"]').on 'focusin', ->
    $(this).autocomplete("/people/auto_complete_for_person_first_name_middle_name_last_name_email")

  $('input[name="role[person]"]').on 'keyup', (e) ->
    $(this).closest('form').find('a.toggle-adding-role').click() if e.keyCode is 27

  $('input[name="role[person]"]:visible').first().blur().focus()
