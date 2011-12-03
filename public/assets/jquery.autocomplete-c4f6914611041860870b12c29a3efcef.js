/*
 * Autocomplete - jQuery plugin 1.0.2
 *
 * Copyright (c) 2007 Dylan Verheul, Dan G. Switzer, Anjesh Tuladhar, Jörn Zaefferer
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * Revision: $Id: jquery.autocomplete.js 5747 2008-06-25 18:30:55Z joern.zaefferer $
 *
 */
(function(a){a.fn.extend({autocomplete:function(b,c){var d=typeof b=="string";return c=a.extend({},a.Autocompleter.defaults,{url:d?b:null,data:d?null:b,delay:d?a.Autocompleter.defaults.delay:10,max:c&&!c.scroll?10:150},c),c.highlight=c.highlight||function(a){return a},c.formatMatch=c.formatMatch||c.formatItem,this.each(function(){new a.Autocompleter(this,c)})},result:function(a){return this.bind("result",a)},search:function(a){return this.trigger("search",[a])},flushCache:function(){return this.trigger("flushCache")},setOptions:function(a){return this.trigger("setOptions",[a])},unautocomplete:function(){return this.trigger("unautocomplete")}}),a.Autocompleter=function(b,c){function n(){var a=l.selected();if(!a)return!1;var b=a.result;g=b;if(c.multiple){var d=p(e.val());d.length>1&&(b=d.slice(0,d.length-1).join(c.multipleSeparator)+c.multipleSeparator+b),b+=c.multipleSeparator}return e.val(b),t(),e.trigger("result",[a.data,a.value]),!0}function o(a,b){if(j==d.DEL){l.hide();return}var f=e.val();if(!b&&f==g)return;g=f,f=q(f),f.length>=c.minChars?(e.addClass(c.loadingClass),c.matchCase||(f=f.toLowerCase()),v(f,u,t)):(x(),l.hide())}function p(b){if(!b)return[""];var d=b.split(c.multipleSeparator),e=[];return a.each(d,function(b,c){a.trim(c)&&(e[b]=a.trim(c))}),e}function q(a){if(!c.multiple)return a;var b=p(a);return b[b.length-1]}function r(f,h){c.autoFill&&q(e.val()).toLowerCase()==f.toLowerCase()&&j!=d.BACKSPACE&&(e.val(e.val()+h.substring(q(g).length)),a.Autocompleter.Selection(b,g.length,g.length+h.length))}function s(){clearTimeout(f),f=setTimeout(t,200)}function t(){var d=l.visible();l.hide(),clearTimeout(f),x();if(c.mustMatchCache){var g=e.attr("value");if(!h.contains(g)){if(c.multiple){var i=p(e.val()).slice(0,-1);e.val(i.join(c.multipleSeparator)+(i.length?c.multipleSeparator:""))}else e.val("");c.afterNoMatch();if(c.hiddenId!=""){var j=a(c.hiddenId);j.attr("value","")}}}else c.mustMatch&&e.search(function(b){if(!b){if(c.multiple){var d=p(e.val()).slice(0,-1);e.val(d.join(c.multipleSeparator)+(d.length?c.multipleSeparator:""))}else e.val("");c.afterNoMatch();if(c.hiddenId!=""){var f=a(c.hiddenId);f.attr("value","")}}});d&&a.Autocompleter.Selection(b,b.value.length,b.value.length)}function u(a,b){b&&b.length&&i?(x(),l.display(b,a),r(a,b[0].value),l.show()):t()}function v(d,e,f){c.matchCase||(d=d.toLowerCase());var g=h.load(d);if(g&&g.length)e(d,g);else if(typeof c.url=="string"&&c.url.length>0){var i={timestamp:+(new Date)};a.each(c.extraParams,function(a,b){i[a]=typeof b=="function"?b():b}),a.ajax({mode:"abort",port:"autocomplete"+b.name,dataType:c.dataType,url:c.url,data:a.extend({q:q(d),limit:c.max},i),success:function(a){var b=c.parse&&c.parse(a)||w(a);h.add(d,b),e(d,b)}})}else l.emptyList(),f(d)}function w(b){var d=[],e=b.split("\n");for(var f=0;f<e.length;f++){var g=a.trim(e[f]);g&&(g=g.split("|"),d[d.length]={data:g,value:g[0],result:c.formatResult&&c.formatResult(g,g[0])||g[0]})}return d}function x(){e.removeClass(c.loadingClass)}var d={UP:38,DOWN:40,DEL:46,TAB:9,RETURN:13,ESC:27,COMMA:188,PAGEUP:33,PAGEDOWN:34,BACKSPACE:8},e=a(b).attr("autocomplete","off").addClass(c.inputClass),f,g="",h=a.Autocompleter.Cache(c),i=0,j,k={mouseDownOnSelect:!1},l=a.Autocompleter.Select(c,b,n,k),m;a.browser.opera&&a(b.form).bind("submit.autocomplete",function(){if(m)return m=!1,!1}),e.bind((a.browser.opera?"keypress":"keydown")+".autocomplete",function(b){j=b.keyCode;switch(b.keyCode){case d.UP:b.preventDefault(),l.visible()?l.prev():o(0,!0);break;case d.DOWN:b.preventDefault(),l.visible()?l.next():o(0,!0);break;case d.PAGEUP:b.preventDefault(),l.visible()?l.pageUp():o(0,!0);break;case d.PAGEDOWN:b.preventDefault(),l.visible()?l.pageDown():o(0,!0);break;case c.multiple&&a.trim(c.multipleSeparator)==","&&d.COMMA:case d.TAB:case d.RETURN:if(n())return b.preventDefault(),m=!0,!1;break;case d.ESC:l.hide();break;default:clearTimeout(f),f=setTimeout(o,c.delay)}}).focus(function(){i++}).blur(function(){i=0,k.mouseDownOnSelect||s()}).click(function(){i++>1&&!l.visible()&&o(0,!0)}).bind("search",function(){function c(a,c){var d;if(c&&c.length)for(var f=0;f<c.length;f++)if(c[f].result.toLowerCase()==a.toLowerCase()){d=c[f];break}typeof b=="function"?b(d):e.trigger("result",d&&[d.data,d.value])}var b=arguments.length>1?arguments[1]:null;a.each(p(e.val()),function(a,b){v(b,c,c)})}).bind("flushCache",function(){h.flush()}).bind("setOptions",function(){a.extend(c,arguments[1]),"data"in arguments[1]&&h.populate()}).bind("unautocomplete",function(){l.unbind(),e.unbind(),a(b.form).unbind(".autocomplete")})},a.Autocompleter.defaults={inputClass:"ac_input",resultsClass:"ac_results",loadingClass:"ac_loading",minChars:1,delay:400,matchCase:!1,matchSubset:!0,matchContains:!1,cacheLength:10,max:100,mustMatch:!1,hiddenId:"",afterNoMatch:function(){return},matchMatchCache:!1,extraParams:{},selectFirst:!0,formatItem:function(a){return a[0]},formatMatch:null,autoFill:!1,width:0,multiple:!1,multipleSeparator:", ",highlight:function(a,b){return a.replace(new RegExp("(?![^&;]+;)(?!<[^<>]*)("+b.replace(/([\^\$\(\)\[\]\{\}\*\.\+\?\|\\])/gi,"\\$1")+")(?![^<>]*>)(?![^&;]+;)","gi"),"<strong>$1</strong>")},scroll:!0,scrollHeight:180},a.Autocompleter.Cache=function(b){function e(a,c){return b.matchCase||(a=a.toLowerCase(),c=c.toLowerCase()),a==c}function f(a,c){b.matchCase||(a=a.toLowerCase());var d=a.indexOf(c);return b.matchContains=="word"&&(d=a.toLowerCase().search("\\b"+c.toLowerCase())),d==-1?!1:d==0||b.matchContains}function g(a,e){d>b.cacheLength&&i(),c[a]||d++,c[a]=e}function h(){if(!b.data)return!1;var c={},d=0;b.url||(b.cacheLength=1),c[""]=[];for(var e=0,f=b.data.length;e<f;e++){var h=b.data[e];h=typeof h=="string"?[h]:h;var i=b.formatMatch(h,e+1,b.data.length);if(i===!1)continue;var j=i.charAt(0).toLowerCase();c[j]||(c[j]=[]);var k={value:i,data:h,result:b.formatResult&&b.formatResult(h)||i};c[j].push(k),d++<b.max&&c[""].push(k)}a.each(c,function(a,c){b.cacheLength++,g(a,c)})}function i(){c={},d=0}function j(b){var d=!1;for(var f in c){if(f.length>0){var g=c[f];a.each(g,function(a,c){if(e(c.value,b))return d=!0,!1})}if(d)break}return d}var c={},d=0;return setTimeout(h,25),{flush:i,add:g,populate:h,contains:j,load:function(e){var g=j(e);if(!b.cacheLength||!d)return null;if(!b.url&&b.matchContains){var h=[];for(var i in c)if(i.length>0){var k=c[i];a.each(k,function(a,b){f(b.value,e)&&h.push(b)})}return h}if(c[e])return c[e];if(b.matchSubset)for(var l=e.length-1;l>=b.minChars;l--){var k=c[e.substr(0,l)];if(k){var h=[];return a.each(k,function(a,b){f(b.value,e)&&(h[h.length]=b)}),h}}return null}}},a.Autocompleter.Select=function(b,c,d,e){function n(){if(!k)return;l=a("<div/>").hide().addClass(b.resultsClass).css("position","absolute").appendTo(document.body),m=a("<ul/>").appendTo(l).mouseover(function(b){o(b).nodeName&&o(b).nodeName.toUpperCase()=="LI"&&(h=a("li",m).removeClass(f.ACTIVE).index(o(b)),a(o(b)).addClass(f.ACTIVE))}).click(function(b){return a(o(b)).addClass(f.ACTIVE),d(),c.focus(),!1}).mousedown(function(){e.mouseDownOnSelect=!0}).mouseup(function(){e.mouseDownOnSelect=!1}),b.width>0&&l.css("width",b.width),k=!1}function o(a){var b=a.target;while(b&&b.tagName!="LI")b=b.parentNode;return b?b:[]}function p(a){g.slice(h,h+1).removeClass(f.ACTIVE),q(a);var c=g.slice(h,h+1).addClass(f.ACTIVE);if(b.scroll){var d=0;g.slice(0,h).each(function(){d+=this.offsetHeight}),d+c[0].offsetHeight-m.scrollTop()>m[0].clientHeight?m.scrollTop(d+c[0].offsetHeight-m.innerHeight()):d<m.scrollTop()&&m.scrollTop(d)}}function q(a){h+=a,h<0?h=g.size()-1:h>=g.size()&&(h=0)}function r(a){return b.max&&b.max<a?b.max:a}function s(){m.empty();var c=r(i.length);for(var d=0;d<c;d++){if(!i[d])continue;var e=b.formatItem(i[d].data,d+1,c,i[d].value,j);if(e===!1)continue;var k=a("<li/>").html(b.highlight(e,j)).addClass(d%2==0?"ac_even":"ac_odd").appendTo(m)[0];a.data(k,"ac_data",i[d])}g=m.find("li"),b.selectFirst&&(g.slice(0,1).addClass(f.ACTIVE),h=0),a.fn.bgiframe&&m.bgiframe()}var f={ACTIVE:"ac_over"},g,h=-1,i,j="",k=!0,l,m;return{display:function(a,b){n(),i=a,j=b,s()},next:function(){p(1)},prev:function(){p(-1)},pageUp:function(){h!=0&&h-8<0?p(-h):p(-8)},pageDown:function(){h!=g.size()-1&&h+8>g.size()?p(g.size()-1-h):p(8)},hide:function(){l&&l.hide(),g&&g.removeClass(f.ACTIVE),h=-1},visible:function(){return l&&l.is(":visible")},current:function(){return this.visible()&&(g.filter("."+f.ACTIVE)[0]||b.selectFirst&&g[0])},show:function(){var d=a(c).offset();l.css({width:typeof b.width=="string"||b.width>0?b.width:a(c).width(),top:d.top+c.offsetHeight,left:d.left}).show();if(b.scroll){m.scrollTop(0),m.css({maxHeight:b.scrollHeight,overflow:"auto"});if(a.browser.msie&&typeof document.body.style.maxHeight=="undefined"){var e=0;g.each(function(){e+=this.offsetHeight});var f=e>b.scrollHeight;m.css("height",f?b.scrollHeight:e),f||g.width(m.width()-parseInt(g.css("padding-left"))-parseInt(g.css("padding-right")))}}},selected:function(){var b=g&&g.filter("."+f.ACTIVE).removeClass(f.ACTIVE);return b&&b.length&&a.data(b[0],"ac_data")},emptyList:function(){m&&m.empty()},unbind:function(){l&&l.remove()}}},a.Autocompleter.Selection=function(a,b,c){if(a.createTextRange){var d=a.createTextRange();d.collapse(!0),d.moveStart("character",b),d.moveEnd("character",c),d.select()}else a.setSelectionRange?a.setSelectionRange(b,c):a.selectionStart&&(a.selectionStart=b,a.selectionEnd=c);a.focus()}})(jQuery)