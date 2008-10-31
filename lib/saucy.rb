require 'rvg/rvg'
include Magick
require "json"
require "base64"

module Saucy
  
class RenderTTF

  @@font_store = "#{RAILS_ROOT}/vendor/plugins/saucy/fonts/"
  @@output = "#{RAILS_ROOT}/public/saucy/images/"
  
  
  def self.render file
    attrs = self.parse(file)
    attrs["size"] = attrs["size"].to_i
    attrs["stroke_width"] = attrs["stroke_width"].to_i

    attrs["stroke_color"].gsub!('HX','#') if attrs["stroke_color"]
    attrs["color"].gsub!('HX','#') if attrs["color"]
    attrs["shadow_color"].gsub!('HX','#') if attrs["shadow_color"]
    
    image = self.draw(attrs)
    image = shadow_render image, attrs if attrs["shadow_color"] 
    
    image.write(@@output + file + ".png")
    return image
  end
  
  def self.draw attrs
    
    attrs = {"size"=>10, "stroke_width" => 0, "background" => "transparent", "color" => "#000", "text" => "no text!", "stroke_color" => "#000"}.merge(attrs)
    
    
    width = attrs["size"]*attrs["text"].length + attrs["stroke_width"]*2
    height = attrs["size"]*2+ attrs["stroke_width"]*2
    
    #throw attrs.inspect
    rvg = RVG.new(width, height) do |canvas|
      canvas.background_fill = attrs["background"] if attrs["background"] != 'transparent'
      
      font_file = @@font_store + attrs["font"]+".ttf"
      sw = attrs["stroke_width"]

      if attrs["stroke_width"] == 0 
        canvas.text(0+sw,attrs["size"]+sw, attrs["text"]).styles(:font => '"' + font_file + '"', :font_size=>attrs["size"], :fill=>attrs["color"])
	    else
		    canvas.text(0+sw,attrs["size"]+sw, attrs["text"]).styles(:font => '"' + font_file + '"', :font_size=>attrs["size"], :fill=>attrs["color"], :stroke => attrs["stroke_color"], :stroke_width => attrs["stroke_width"])
  	  end
      
#      if stroke_inside > 0
#         canvas.text(0+sw,font_size+sw, text).styles(:font => '"' + font_file +'"', :font_size => font_size, :fill=> color, :stroke_width => stroke_inside, :stroke => color )
#      end
    end
    img = rvg.draw
    return img.trim
  end
  
  def self.shadow_render input, attrs
   
    shadow_color = (attrs['shadow_color'] || 'black')
    shadow_opacity = 255 - ((attrs['shadow_opacity'] || '0.6').to_f * 255).to_i
    shadow_top = (attrs['shadow_top'] || '2').to_i 
    shadow_left = (attrs['shadow_left'] || '2').to_i 
    blur_radius = (attrs['shadow_blur'] || '5').to_f
    
    w=input.columns+ blur_radius*4+shadow_left.abs*2
    h=input.rows+ blur_radius*4+shadow_top.abs*2
   
    input.matte = true
    
    opacity_color = "rgb(#{shadow_opacity},#{shadow_opacity},#{shadow_opacity})"
    input_colorized= input.copy.colorize(1.0, 1.0, 1.0, opacity_color)
    
    shadow_mask =  Image.new(w,h ){self.background_color = '#fff'}
    
    zero=[shadow_left.abs+blur_radius,shadow_top.abs+blur_radius]
    
    shadow_mask.composite!(input_colorized, blur_radius, blur_radius, OverCompositeOp)

    shadow_mask.matte=true
    shadow_mask = shadow_mask.blur_image(blur_radius,blur_radius)
 
    output = Image.new(w,h){self.background_color = shadow_color}
    inverse_shadow_mask = shadow_mask.negate
    inverse_shadow_mask.matte = false

    output.matte = true
    output.composite!(inverse_shadow_mask, zero[0]+shadow_left,zero[1]+shadow_top, CopyOpacityCompositeOp)
    output.composite!(input, zero[0]+blur_radius,zero[1]+blur_radius, OverCompositeOp)

  
    return output.trim
  end
  

  @@keys = {
    "b" => "background",
    "t" => "text",
    "s" => "size",
    "c" => "color",
    "f" => "font",
    "sw" => "stroke_width",
    "sc" => "stroke_color",
    "shc" => "shadow_color",
    "sho" => "shadow_opacity",
    "shl" => "shadow_left",
    "sht" => "shadow_top",
    "shb" => "shadow_blur"
  }
  
  def self.parse file
    params = file.gsub(".png","").split("__")
    
    attrs = {}
    
    params.each do |param|
      p = param.split("==")
      key = p[0]
      val = p[1]
      attrs[@@keys[key]] = val
    end
    
    attrs
  end

=begin
  def rotate_render input, attrs
    angle=attrs['pr'].to_i
    input.matte = true
    input.rotate!(angle)
    return input
  end


  def guassian_blur_render input, attrs
    blur_radius = (attrs['pg'] || '10').to_f
    w=input.columns#+ blur_radius*2
    h=input.rows#+ blur_radius*2
    output = Image.new(w,h) {self.background_color = 'transparent'}
    
    blur = input.blur_image(blur_radius/2,blur_radius/2)
    output.composite!(blur, 0,0, OverCompositeOp)
    output
  end
=end

end

end

  



