$(function(){

  $('li:regex(class,(submission|packlet)) header h2').live('click', function(e){
    e.preventDefault();
    $(this).parents('li:regex(class,(submission|packlet))').toggleClass('collapsed');
  });

  $('li:regex(class,(submission|packlet))').draggable({
    handle: 'span.drag-handle-wrap',
    axis: 'y',
    stack: 'article',
    zIndex: 1,
    helper: function(){
      return $(this).clone().css('width', this.offsetWidth)[0];
    }
  });

  $('article section').droppable({
    hoverClass: 'drop-here',
    drop: function( event, ui ) {
      li = ui.draggable;
      section = $(this);
      if(section.hasClass('unscheduled') && li.hasClass('packlet')) {
        packlet_id = li.attr('id').split('_')[1];
        $.ajax({
          type: 'DELETE',
          url: '/packlets/' + packlet_id
        }); }
      else if(li.parents('section').attr('id') != section.attr('id')) {
        if(li.hasClass('submission')) {
          $.ajax({
            type: 'POST',
            url: '/packlets',
            data: {
              submission: li.attr('id').split('_').pop(),
              meeting:     section.attr('id').split('_').pop() }
          }); }
        else {
          $.ajax({
            type: 'POST',
            url: '/packlets',
            data: {
              packlet:  li.attr('id').split('_')[1],
              meeting: section.attr('id').split('_')[1] }
          });
        }
      }
    }
  });

});
