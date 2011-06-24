$(function(){
  var width = 200;
  $('li.submission').draggable({
    handle: 'span.drag-handle-wrap',
    zIndex: 1,
    helper: function(){
      var text = $(this).find('header h2').clone().text();
      if (text.length > 20)
        text = text.substring(0, 20) + "&hellip;";

      return $('<h2 class="nocaps"></h2>').html(
        text
      ).css({
        width: width
      });
    },
    cursorAt: {
      left: width / 2,
      top: -10
    }
    ,drag: function(event, ui){
      ui.position.left = event.pageX + 15;
    }
  });

  $('li.page').droppable({
    hoverClass: 'drop-here',
    drop: function(event, ui) {
      var submission = ui.draggable,
          to_page    = $(this).text();
      console.info("Moving to page #" + to_page);
      submission.hide();
    }
  });
});
