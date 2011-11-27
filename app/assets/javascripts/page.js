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
          submission_id = submission.attr('id').split('_').pop(),
          to_page    = $(this).text(),
          to_path    = window.location.pathname.split('/'),
          from_page  = to_path.splice(3,1,to_page);
      to_path = to_path.join('/');

      console.info("Moving submission " + submission_id + " to " + to_path);

      $.ajax({
        type: 'PUT',
        dataType: 'script',
        url: to_path + '/add_submission',
        data: {
          submission_id: submission_id
        },
        beforeSend: function(jqXHR, settings){
          submission.css('border-style', 'dotted');
        },
        success: function(data, textStatus, jqXHR){
          if (to_page == from_page) {
            submission.css('border-style', 'dashed').parents('ol').prepend(submission);
          } else {
            submission.hide();
          }
        },
        error: function(data, textStatus, jqXHR){
          submission.addClass('error').removeAttr('style');
        }
      });
    }
  });
});
