$(function(){

  $('li.composition header h2').live('click', function(e){
    e.preventDefault();
    $(this).parents('li.composition').toggleClass('collapsed');
  });

  $('li.composition').draggable({
    stack: 'article',
    zIndex: 1,
    helper: 'clone'
  });

  $('section').droppable({
    hoverClass: 'drop-here',
    drop: function( event, ui ) {
      $.ajax({
        type: 'POST',
        url: '/packets',
        data: {
          meeting: $(this).attr('id'),
          composition:   ui.draggable.attr('id') }
      });
    }
  });

});
