$(function(){

  $('li:regex(class,(composition|packet)) header h2').live('click', function(e){
    e.preventDefault();
    $(this).parents('li:regex(class,(composition|packet))').toggleClass('collapsed');
  });

  $('li:regex(class,(composition|packet))').draggable({
    axis: 'y',
    stack: 'article',
    zIndex: 1,
    helper: 'clone'
  });

  $('section').droppable({
    hoverClass: 'drop-here',
    drop: function( event, ui ) {
      $.ajax({
        type: 'POST',
        url: '/packets/create_update_or_destroy',
        data: {
          the_thing:   ui.draggable.attr('id'),
          coming_from: ui.draggable.parents('li.regex(class,(composition|packet))').attr('id'),
          going_to:    $(this).attr('id') }
      });
    }
  });

});
