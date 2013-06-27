jQuery ->
  $(document).on 'click', 'a.toggle-adding-role', (e) ->
    e.preventDefault()
    $(this).closest('footer').toggleClass('add-role')

  $(document).on 'focusin', 'input[name="role[person]"]', ->
    $(this).autocomplete("/people/auto_complete_for_person_first_name_middle_name_last_name_email")

  $(document).on 'keyup', 'input[name="role[person]"]', (e) ->
    $(this).closest('form').find('a.toggle-adding-role').click() if e.keyCode is 27

  $('input[name="role[person]"]:visible').first().blur().focus()
