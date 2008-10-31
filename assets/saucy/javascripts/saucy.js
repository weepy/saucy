// Saucy
;(function($){

  var saucyRoot = "/saucy/images/"
  var pixel = "/saucy/pixel.gif"
  
  var ie6filter = function(src) {
    return  "progid:DXImageTransform.Microsoft.AlphaImageLoader(enabled=true,sizingMethod=crop,src='"+src+"')";
  }
  
  var ie6 = $.browser.msie && /MSIE\s(5\.5|6\.)/.test(navigator.userAgent);

  var pngfixIE6 = function() {
       var $$ = $(this)
        var src = $$.attr('src')
        if(src == pixel)
          return

        $$.css({filter: ie6filter(src), width: $$.width(), height: $$.height()})
		      .attr({src: pixel})
	  
		  var position = $$.css('position');
			if (position != 'absolute' && position != 'relative') {
				$$.css({position:'relative'});
			}
		}
		
	var keys = {
	  background: "b",
	  text: "t",
	  size: "s",
	  color: "c",
	  font: "f",
	  stroke_width: "sw",
	  stroke_color: "sc",
    shadow_color: "shc",
    shadow_opacity: "sho",
    shadow_left: "shl",
    shadow_top: "sht",
    shadow_blur: "shb"	
	}
	
		
	
	var saucyURL = function(style, text) {
	  var url = ["t" + "==" + escape(text)]
	  for(var key in style) {
	    var c = keys[key]
	    if(c)
        url.push(c + "==" + style[key])
	  }
	  return (saucyRoot + url.join("__"))
	}

   
  $.fn.saucy = function(style, pngfix) {
    
    return this.each(function() {
      var $$ = $(this)
      var img = $("<img>").attr("src", saucyURL(style, $$.html()) + '.png');
      
      if(ie6 && pngfix) {
        img.load(pngfixIE6)
      }
         
      $$.html(img)

     })
   }
})(jQuery);
