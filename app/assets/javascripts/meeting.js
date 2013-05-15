var score_timers = [];

function submitScoreWithDelay(score_form_element) {
  var span = $(score_form_element).closest('span');
  var score_id = span.attr('data-attendee') + span.attr('data-packlet');

  /* check to see if there's already a timer running for this score */
  if (!score_timers[score_id]) {
    /* if not, go ahead and submit this one with a delay */
    score_timers[score_id] = setTimeout(function() {
      score_form_element.submit();
    }, 500);
  }

}

$(function(){

  $("#attendee_person").live('focus blur', function(event){
    if (event.type == 'focusin') {
      $(this).autocomplete("/people/auto_complete_for_person_first_name_middle_name_last_name_email"); }
    else {
      if($(this).val() == '')
        $('span.name').html($(this).val().split(' ')[0].replace(/"/g, ''));
      else
        $('span.name').html($(this).val().split(' ')[0].replace(/"/g, '') + "'s");
    }});

  $('ol.packlets.sortable').sortable({
    axis: 'y',
    items: 'li',
    handle: 'span.drag-handle-wrap',
    update: function(event, ui){
      li = ui.item;
      packlet_id = li.attr('id').split('_')[1];
      $.ajax({
        type: 'PUT',
        dataType: 'script',
        url: '/packlets/' + packlet_id + '/update_position',
        data: { position: li.prevAll().length }
      });
    }
  });

  $('div.scores-wrap').css({ width: ($('div.scores').length * 55) });
  $('form.score input[type=submit]').hide();
  $('input[type=number]').live('mouseout blur', function(){
    var orig    = $(this).attr('data-original'),
        current = $(this).val();
    if (orig != current) {
      submitScoreWithDelay($(this));
    }
  });

  $('form#new_attendee[data-remote]').live('ajax:before', function(){
    attendee_email = $(this).find("input#attendee_person").val().split(' ').pop();
    if ($(this).attr('data-viewer') == attendee_email) {
      $(this).submit(); }
    $(this).append("<img src='/assets/indicator.gif' class='indicator' alt='loading'/>");
  }).live('ajax:complete', function(){
    $(this).find('img.indicator').remove();
  });

});