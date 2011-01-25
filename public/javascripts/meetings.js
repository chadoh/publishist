$(function(){

  $('li:regex(class,(submission|packlet)) header h2').live('click', function(e){
    e.preventDefault();
    $(this).parents('li:regex(class,(submission|packlet))').toggleClass('collapsed');
  });

  $("#attendee_person").live('focus blur', function(event){
    if (event.type == 'focusin') {
      $(this).autocomplete("/people/auto_complete_for_person_first_name_middle_name_last_name_email"); }
    else {
      if($(this).val() == '')
        $('span.name').html($(this).val().split(' ')[0].replace(/"/g, ''));
      else
        $('span.name').html($(this).val().split(' ')[0].replace(/"/g, '') + "'s");
    }});

  $('ol.packlets').sortable({
    axis: 'y',
    items: 'li',
    handle: 'span.drag-handle-wrap',
    update: function(event, ui){
      li = ui.item;
      packlet_id = li.attr('id').split('_')[1];
      $.ajax({
        type: 'PUT',
        url: '/packlets/' + packlet_id + '/update_position',
        data: { position: li.prevAll().length }
      });
    }
  });

  $('form.score input[type=submit]').hide();
  $('input[type=number]').live('mouseout blur', function(){
    var orig    = $(this).attr('data-original'),
        current = $(this).val();
    if (orig != current) {
      $(this).parents('form').submit();
    }
  });

  $('form#new_attendee[data-remote]').live('ajax:before', function(){
    attendee_email = $(this).find("input#attendee_person").val().split(',')[1].replace(' ', '');
    if ($(this).attr('data-viewer') == attendee_email) {
      $(this).submit(); }
  });

  $('span.actions a.edit').live('click', function(e){
    e.preventDefault();
    $.ajax({
      url: $(this).attr('href')
    });
  });
});
