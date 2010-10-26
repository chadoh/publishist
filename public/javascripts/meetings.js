$(function(){

  $("#attendance_person").autocomplete("/people/auto_complete_for_person_first_name_middle_name_last_name_email")
    .live('blur', function() {
      if($(this).val() == '')
        $('span.name').html($(this).val().split(' ')[0].replace(/"/g, ''));
      else
        $('span.name').html($(this).val().split(' ')[0].replace(/"/g, '') + "'s");
    });

  $('span.drag-handle').css('display', 'inline-block')
  $('ol.packets').sortable({
    axis: 'y',
    items: 'li',
    handle: 'span.drag-handle',
    update: function(event, ui){
      li = ui.item;
      packet_id = li.attr('id').split('_')[1];
      $.ajax({
        type: 'PUT',
        url: '/packets/' + packet_id + '/update_position',
        data: { position: li.prevAll().length }
      });
    }
  });
});
