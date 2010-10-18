$(function(){

  $('li.composition header h2').live('click', function(e){
    e.preventDefault();
    $(this).parents('li.composition').toggleClass('collapsed');
  });

  $('li.composition').draggable({
    revert: true,
    revertDuration: 150,
    stack: 'article',
    zIndex: 1,
    helper: 'clone'
  });

});
