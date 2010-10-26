$(function(){

  $('li:regex(class,(composition|packet)) header h2').live('click', function(e){
    e.preventDefault();
    $(this).parents('li:regex(class,(composition|packet))').toggleClass('collapsed');
  });

  $('span.drag-handle').css('display', 'inline-block')
  $('li:regex(class,(composition|packet))').draggable({
    handle: 'span.drag-handle',
    axis: 'y',
    stack: 'article',
    zIndex: 1,
    helper: 'clone'
  });

  $('section').droppable({
    hoverClass: 'drop-here',
    drop: function( event, ui ) {
      li = ui.draggable;
      section = $(this);
      if(section.hasClass('unscheduled') && li.hasClass('packet')) {
        packet_id = li.attr('id').split('_')[1];
        $.ajax({
          type: 'DELETE',
          url: '/packets/' + packet_id
        }); }
      else if(li.parents('section').attr('id') != section.attr('id')) {
        if(li.hasClass('composition')) {
          $.ajax({
            type: 'POST',
            url: '/packets',
            data: {
              composition: li.attr('id').split('_')[1],
              meeting:     section.attr('id').split('_')[1] }
          }); }
        else {
          $.ajax({
            type: 'POST',
            url: '/packets',
            data: {
              packet:  li.attr('id').split('_')[1],
              meeting: section.attr('id').split('_')[1] }
          });
        }
      }
    }
  });

});
