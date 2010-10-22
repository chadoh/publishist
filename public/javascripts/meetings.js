$(function(){

  $("#attendance_person").autocomplete("/people/auto_complete_for_person_first_name_middle_name_last_name_email")
    .live('blur', function() {
      if($(this).val() == '')
        $('span.name').html($(this).val().split(' ')[0].replace(/"/g, ''));
      else
        $('span.name').html($(this).val().split(' ')[0].replace(/"/g, '') + "'s");
    });

  $('li:regex(class,(composition|packet)) header h2').live('click', function(e){
    e.preventDefault();
    $(this).parents('li:regex(class,(composition|packet))').toggleClass('collapsed');
  });

});
