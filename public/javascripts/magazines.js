$(function(){
  $('li.meeting').draggable({
    handle: 'span.drag-handle-wrap',
    axis: 'y',
    stack: 'article',
    zIndex: 1,
    helper: function(){
      return $(this).clone().css('width', this.offsetWidth)[0];
    }
  });
  $('li.magazine').droppable({
    hoverClass: 'drop-here',
    drop: function( event, ui ) {
      meeting_id  = ui.draggable.attr('id').split('_').pop();
      magazine_id = $(this).attr('id').split('_').pop();
      $.ajax({
        type: 'PUT',
        url:  '/meetings/' + meeting_id,
        dataType: 'script',
        data: {
          meeting: {
            magazine_id: magazine_id
          }
        }
      });
    }
  });
});
