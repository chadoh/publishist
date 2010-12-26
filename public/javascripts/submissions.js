$(function(){

  $('li:regex(class,(submission|packet)) header h2').live('click', function(e){
    e.preventDefault();
    $(this).parents('li:regex(class,(submission|packet))').toggleClass('collapsed');
  });

  $('li:regex(class,(submission|packet))').draggable({
    handle: 'span.drag-handle-wrap',
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
        if(li.hasClass('submission')) {
          $.ajax({
            type: 'POST',
            url: '/packets',
            data: {
              submission: li.attr('id').split('_')[1],
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
