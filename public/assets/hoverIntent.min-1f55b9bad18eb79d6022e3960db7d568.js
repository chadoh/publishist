/**
* hoverIntent r5 // 2007.03.27 // jQuery 1.1.2+
* <http://cherne.net/brian/resources/jquery.hoverIntent.html>
* 
* @param  f  onMouseOver function || An object with configuration options
* @param  g  onMouseOut function  || Nothing (use configuration options object)
* @author    Brian Cherne <brian@cherne.net>
*/
(function(a){a.fn.hoverIntent=function(b,c){var d={sensitivity:7,interval:100,timeout:0};d=a.extend(d,c?{over:b,out:c}:b);var e,f,g,h,i=function(a){e=a.pageX,f=a.pageY},j=function(b,c){c.hoverIntent_t=clearTimeout(c.hoverIntent_t);if(Math.abs(g-e)+Math.abs(h-f)<d.sensitivity)return a(c).unbind("mousemove",i),c.hoverIntent_s=1,d.over.apply(c,[b]);g=e,h=f,c.hoverIntent_t=setTimeout(function(){j(b,c)},d.interval)},k=function(a,b){return b.hoverIntent_t=clearTimeout(b.hoverIntent_t),b.hoverIntent_s=0,d.out.apply(b,[a])},l=function(b){var c=(b.type=="mouseover"?b.fromElement:b.toElement)||b.relatedTarget;while(c&&c!=this)try{c=c.parentNode}catch(b){c=this}if(c==this)return!1;var e=jQuery.extend({},b),f=this;f.hoverIntent_t&&(f.hoverIntent_t=clearTimeout(f.hoverIntent_t)),b.type=="mouseover"?(g=e.pageX,h=e.pageY,a(f).bind("mousemove",i),f.hoverIntent_s!=1&&(f.hoverIntent_t=setTimeout(function(){j(e,f)},d.interval))):(a(f).unbind("mousemove",i),f.hoverIntent_s==1&&(f.hoverIntent_t=setTimeout(function(){k(e,f)},d.timeout)))};return this.mouseover(l).mouseout(l)}})(jQuery)