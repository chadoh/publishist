
jQuery.expr[':'].regex = function(elem, index, match) {
    var matchParams = match[3].split(','),
        validLabels = /^(data|css):/,
        attr = {
            method: matchParams[0].match(validLabels) ? 
                        matchParams[0].split(':')[0] : 'attr',
            property: matchParams.shift().replace(validLabels,'')
        },
        regexFlags = 'ig',
        regex = new RegExp(matchParams.join('').replace(/^\s+|\s+$/g,''), regexFlags);
    return regex.test(jQuery(elem)[attr.method](attr.property));
}

$(function(){

  Modernizr.addTest('meter', function(){
    return 'value' in document.createElement('meter');
  });

  $('a.toggle_next').next().hide().end().live('click', function(e){
    e.preventDefault();
    $(this).next().slideToggle();
  });

  $('dd').hide();
  $('dt').live('click', function(e){
    $(this).find('span.arrow').toggleClass("rotated");
    $(this).next().slideToggle();
  });
  setTimeout(function(){
    $('dt').first().click()
  }, 1000);

  $("li.attendee nav.actions form[data-remote]").live("ajax:success", function(){
    $(this).closest('nav').closest('li').fadeOut();
  });

  $("*[contenteditable]").live({
    blur: function(e, triggered_by_keypress){
      if (!triggered_by_keypress) {
        var model     = $(this).attr("data-model"),
            attribute = $(this).attr("data-attribute") || $(this).attr("class"),
            value     = $(this).text().trim(),
            path      = $(this).attr("data-path"),
            original  = $(this).attr("data-original"),
            updateData = {};
        console.info("original: '" + original + "',", "value: '" + value + "'");
        if (original != value) {
          updateData[model] = {};
          updateData[model][attribute] = value;
          $.ajax({
            type: 'PUT',
            dataType: 'script',
            url:  path,
            data: updateData
          });
        }
      }
    },
    keydown: function(e){
      if (e.keyCode == 13)
        $(this).trigger('blur', [true]);
    }
  });

  if(!Modernizr.inputtypes.number){ $('html').addClass('no-number-input'); }

  if(Modernizr.meter && $('meter[data-average]').length > 0){
    $('meter[data-average]').after(function(){
        return '<span class="average-score" style="margin-left: -' +
                (1 - $(this).attr('data-average')/10) * $(this).width() +
                'px"></span>';
    });
  }

  $(document).ajaxSend(function(event, request, settings) {
    if (typeof(AUTH_TOKEN) == "undefined") return;
    // settings.data is a serialized string like "foo=bar&baz=boink" (or null)
    settings.data = settings.data || "";
    settings.data += (settings.data ? "&" : "") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
  });
});
