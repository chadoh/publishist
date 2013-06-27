/*
 * Modernizr v1.6
 * http://www.modernizr.com
 *
 * Developed by: 
 * - Faruk Ates  http://farukat.es/
 * - Paul Irish  http://paulirish.com/
 *
 * Copyright (c) 2009-2010
 * Dual-licensed under the BSD or MIT licenses.
 * http://www.modernizr.com/license/
 */
window.Modernizr=function(e,t,n){function r(e,t){return(""+e).indexOf(t)!==-1}function a(e,t){for(var r in e)if(m[e[r]]!==n&&(!t||t(e[r],d)))return!0}function o(e,t){var n=e.charAt(0).toUpperCase()+e.substr(1);return n=(e+" "+v.join(n+" ")+n).split(" "),!!a(n,t)}function i(){u.input=function(e){for(var t=0,n=e.length;n>t;t++)T[e[t]]=!!(e[t]in f);return T}("autocomplete autofocus list placeholder max min multiple pattern required step".split(" ")),u.inputtypes=function(e){for(var r,a=0,o=e.length;o>a;a++)f.setAttribute("type",e[a]),(r=f.type!=="text")&&(f.value=p,/^range$/.test(f.type)&&f.style.WebkitAppearance!==n?(l.appendChild(f),r=t.defaultView,r=r.getComputedStyle&&r.getComputedStyle(f,null).WebkitAppearance!=="textfield"&&f.offsetHeight!==0,l.removeChild(f)):/^(search|tel)$/.test(f.type)||(r=/^(url|email)$/.test(f.type)?f.checkValidity&&f.checkValidity()===!1:f.value!=p)),x[e[a]]=!!r;return x}("search tel url email datetime date month week time datetime-local number range color".split(" "))}var c,s,u={},l=t.documentElement,d=t.createElement("modernizr"),m=d.style,f=t.createElement("input"),p=":)",g=Object.prototype.toString,h=" -webkit- -moz- -o- -ms- -khtml- ".split(" "),v="Webkit Moz O ms Khtml".split(" "),y={svg:"http://www.w3.org/2000/svg"},b={},x={},T={},C=[],E=function(e){var n=document.createElement("style"),r=t.createElement("div");return n.textContent=e+"{#modernizr{height:3px}}",(t.head||t.getElementsByTagName("head")[0]).appendChild(n),r.id="modernizr",l.appendChild(r),e=r.offsetHeight===3,n.parentNode.removeChild(n),r.parentNode.removeChild(r),!!e},w=function(){var e={select:"input",change:"input",submit:"form",reset:"form",error:"img",load:"img",abort:"img"};return function(t,r){r=r||document.createElement(e[t]||"div"),t="on"+t;var a=t in r;return a||(r.setAttribute||(r=document.createElement("div")),r.setAttribute&&r.removeAttribute&&(r.setAttribute(t,""),a=typeof r[t]=="function",typeof r[t]!="undefined"&&(r[t]=n),r.removeAttribute(t))),a}}(),k={}.hasOwnProperty;s="undefined"!=typeof k&&typeof k.call!="undefined"?function(e,t){return k.call(e,t)}:function(e,t){return t in e&&typeof e.constructor.prototype[t]=="undefined"},b.flexbox=function(){var e=t.createElement("div"),n=t.createElement("div");(function(e,t,n,r){t+=":",e.style.cssText=(t+h.join(n+";"+t)).slice(0,-t.length)+(r||"")})(e,"display","box","width:42px;padding:0;"),n.style.cssText=h.join("box-flex:1;")+"width:10px;",e.appendChild(n),l.appendChild(e);var r=n.offsetWidth===42;return e.removeChild(n),l.removeChild(e),r},b.canvas=function(){var e=t.createElement("canvas");return!(!e.getContext||!e.getContext("2d"))},b.canvastext=function(){return!(!u.canvas||typeof t.createElement("canvas").getContext("2d").fillText!="function")},b.webgl=function(){var e=t.createElement("canvas");try{if(e.getContext("webgl"))return!0}catch(n){}try{if(e.getContext("experimental-webgl"))return!0}catch(r){}return!1},b.touch=function(){return"ontouchstart"in e||E("@media ("+h.join("touch-enabled),(")+"modernizr)")},b.geolocation=function(){return!!navigator.geolocation},b.postmessage=function(){return!!e.postMessage},b.websqldatabase=function(){return!!e.openDatabase},b.indexedDB=function(){for(var t=-1,n=v.length;++t<n;){var r=v[t].toLowerCase();if(e[r+"_indexedDB"]||e[r+"IndexedDB"])return!0}return!1},b.hashchange=function(){return w("hashchange",e)&&(document.documentMode===n||document.documentMode>7)},b.history=function(){return!(!e.history||!history.pushState)},b.draganddrop=function(){return w("drag")&&w("dragstart")&&w("dragenter")&&w("dragover")&&w("dragleave")&&w("dragend")&&w("drop")},b.websockets=function(){return"WebSocket"in e},b.rgba=function(){return m.cssText="background-color:rgba(150,255,150,.5)",r(m.backgroundColor,"rgba")},b.hsla=function(){return m.cssText="background-color:hsla(120,40%,100%,.5)",r(m.backgroundColor,"rgba")||r(m.backgroundColor,"hsla")},b.multiplebgs=function(){return m.cssText="background:url(//:),url(//:),red url(//:)",/(url\s*\(.*?){3}/.test(m.background)},b.backgroundsize=function(){return o("backgroundSize")},b.borderimage=function(){return o("borderImage")},b.borderradius=function(){return o("borderRadius","",function(e){return r(e,"orderRadius")})},b.boxshadow=function(){return o("boxShadow")},b.textshadow=function(){return t.createElement("div").style.textShadow===""},b.opacity=function(){var e=h.join("opacity:.5;")+"";return m.cssText=e,r(m.opacity,"0.5")},b.cssanimations=function(){return o("animationName")},b.csscolumns=function(){return o("columnCount")},b.cssgradients=function(){var e=("background-image:"+h.join("gradient(linear,left top,right bottom,from(#9f9),to(white));background-image:")+h.join("linear-gradient(left top,#9f9, white);background-image:")).slice(0,-17);return m.cssText=e,r(m.backgroundImage,"gradient")},b.cssreflections=function(){return o("boxReflect")},b.csstransforms=function(){return!!a(["transformProperty","WebkitTransform","MozTransform","OTransform","msTransform"])},b.csstransforms3d=function(){var e=!!a(["perspectiveProperty","WebkitPerspective","MozPerspective","OPerspective","msPerspective"]);return e&&(e=E("@media ("+h.join("transform-3d),(")+"modernizr)")),e},b.csstransitions=function(){return o("transitionProperty")},b.fontface=function(){var e,n=t.head||t.getElementsByTagName("head")[0]||l,r=t.createElement("style"),a=t.implementation||{hasFeature:function(){return!1}};return r.type="text/css",n.insertBefore(r,n.firstChild),e=r.sheet||r.styleSheet,n=a.hasFeature("CSS2","")?function(t){if(!e||!t)return!1;var n=!1;try{e.insertRule(t,0),n=!/unknown/i.test(e.cssRules[0].cssText),e.deleteRule(e.cssRules.length-1)}catch(r){}return n}:function(t){return e&&t?(e.cssText=t,e.cssText.length!==0&&!/unknown/i.test(e.cssText)&&e.cssText.replace(/\r+|\n+/g,"").indexOf(t.split(" ")[0])===0):!1},u._fontfaceready=function(e){e(u.fontface)},n('@font-face { font-family: "font"; src: "font.ttf"; }')},b.video=function(){var e=t.createElement("video"),n=!!e.canPlayType;return n&&(n=new Boolean(n),n.ogg=e.canPlayType('video/ogg; codecs="theora"'),n.h264=e.canPlayType('video/mp4; codecs="avc1.42E01E"')||e.canPlayType('video/mp4; codecs="avc1.42E01E, mp4a.40.2"'),n.webm=e.canPlayType('video/webm; codecs="vp8, vorbis"')),n},b.audio=function(){var e=t.createElement("audio"),n=!!e.canPlayType;return n&&(n=new Boolean(n),n.ogg=e.canPlayType('audio/ogg; codecs="vorbis"'),n.mp3=e.canPlayType("audio/mpeg;"),n.wav=e.canPlayType('audio/wav; codecs="1"'),n.m4a=e.canPlayType("audio/x-m4a;")||e.canPlayType("audio/aac;")),n},b.localstorage=function(){try{return"localStorage"in e&&e.localStorage!==null}catch(t){return!1}},b.sessionstorage=function(){try{return"sessionStorage"in e&&e.sessionStorage!==null}catch(t){return!1}},b.webWorkers=function(){return!!e.Worker},b.applicationcache=function(){return!!e.applicationCache},b.svg=function(){return!!t.createElementNS&&!!t.createElementNS(y.svg,"svg").createSVGRect},b.inlinesvg=function(){var e=document.createElement("div");return e.innerHTML="<svg/>",(e.firstChild&&e.firstChild.namespaceURI)==y.svg},b.smil=function(){return!!t.createElementNS&&/SVG/.test(g.call(t.createElementNS(y.svg,"animate")))},b.svgclippaths=function(){return!!t.createElementNS&&/SVG/.test(g.call(t.createElementNS(y.svg,"clipPath")))};for(var S in b)s(b,S)&&(c=S.toLowerCase(),u[c]=b[S](),C.push((u[c]?"":"no-")+c));return u.input||i(),u.crosswindowmessaging=u.postmessage,u.historymanagement=u.history,u.addTest=function(e,t){return e=e.toLowerCase(),u[e]?void 0:(t=!!t(),l.className+=" "+(t?"":"no-")+e,u[e]=t,u)},m.cssText="",d=f=null,e.attachEvent&&function(){var e=t.createElement("div");return e.innerHTML="<elem></elem>",e.childNodes.length!==1}()&&function(e,t){function n(e){for(var t=-1;++t<o;)e.createElement(a[t])}function r(e,t){for(var n,a=e.length,o=-1,i=[];++o<a;)n=e[o],t=n.media||t,i.push(r(n.imports,t)),i.push(n.cssText);return i.join("")}var a="abbr|article|aside|audio|canvas|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video".split("|"),o=a.length,i=RegExp("<(/*)(abbr|article|aside|audio|canvas|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video)","gi"),c=RegExp("\\b(abbr|article|aside|audio|canvas|details|figcaption|figure|footer|header|hgroup|mark|meter|nav|output|progress|section|summary|time|video)\\b(?!.*[;}])","gi"),s=t.createDocumentFragment(),u=t.documentElement,l=u.firstChild,d=t.createElement("style"),m=t.createElement("body");d.media="all",n(t),n(s),e.attachEvent("onbeforeprint",function(){for(var e=-1;++e<o;)for(var n=t.getElementsByTagName(a[e]),f=n.length,p=-1;++p<f;)n[p].className.indexOf("iepp_")<0&&(n[p].className+=" iepp_"+a[e]);l.insertBefore(d,l.firstChild),d.styleSheet.cssText=r(t.styleSheets,"all").replace(c,".iepp_$1"),s.appendChild(t.body),u.appendChild(m),m.innerHTML=s.firstChild.innerHTML.replace(i,"<$1bdo")}),e.attachEvent("onafterprint",function(){m.innerHTML="",u.removeChild(m),l.removeChild(d),u.appendChild(s.firstChild)})}(this,document),u._enableHTML5=!0,u._version="1.6",l.className=l.className.replace(/\bno-js\b/,"")+" js",l.className+=" "+C.join(" "),u}(this,this.document);