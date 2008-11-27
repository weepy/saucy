require "RMagick" 
require 'rvg/rvg'


module Saucy
  module SaucyRender


    DEFAULT_STYLE = { 
      :background => "transparent",
      :font => {:size=>18, :color => "#000", :font => "arial", :stretch => "normal"},
      :stroke => {:width => 0, :color => "#000", :inner => true },
      :shadow => {:color => "#000", :opacity => 0.6, :top => 2, :left => 2, :blur => 5.0, :render => false },
      :rotate => 0,
      :spacing => {:letter => 0, :word => 0}
    }

    FONT_STORE = "#{RAILS_ROOT}/vendor/plugins/saucy/fonts/"

    def self.saucy_render text, style, filename
      style = DEFAULT_STYLE.merge(style)    
      
      image = draw( text, DEFAULT_STYLE[:font].merge(style[:font]), 
                          style[:background] || DEFAULT_STYLE[:background], 
                          DEFAULT_STYLE[:stroke].merge(style[:stroke]),
                          DEFAULT_STYLE[:spacing].merge(style[:spacing]) )

      if style[:shadow][:render]
        image = shadow_render(image, DEFAULT_STYLE[:shadow].merge(style[:shadow]) )
      end

      if style[:rotate] != 0
        image = rotate_render(image, style[:rotate]) 
      end

      image.write("#{RAILS_ROOT}/public#{filename}")
    end
    
    def self.draw text, font, background, stroke, spacing
      
      lines = text.split("\n")

      width = font[:size]*text.length + stroke[:width]*2

      height = (font[:size]*2 + stroke[:width]*2)*lines.length
      
      
      rvg = Magick::RVG.new(width, height) do |canvas|
        canvas.background_fill = background if background != 'transparent'
        
        sw = stroke[:width]
        
        font_file = font[:font].match(/\./) ? FONT_STORE + font[:font] : font[:font]

        styles = {
          :font => '"' + font_file + '"',
          :font_size=>font[:size], 
          :fill=>font[:color], 
          :font_stretch => font[:stretch],
          :letter_spacing => spacing[:letter],
          :word_spacing => spacing[:word],
          :glyph_orientation_horizontal => font[:rotate]
        }
        
        if stroke[:width] > 0
          styles.merge!( :stroke => stroke[:color], :stroke_width => stroke[:width] )
    	  end
        
        line_height = font[:height] || font[:size]
        y = 0

        lines.each do |line|
         
          canvas.text(sw,font[:size]+y, line).styles(styles)

          if stroke[:inner] && stroke[:width] > 1
            inner = styles.merge(:stroke_width => 1, :stroke => font[:color])
            canvas.text(sw,font[:size]+y, line).styles(inner)
          end
          y += line_height
        end

      end
      img = rvg.draw
      return img.trim
    end
    
    def self.shadow_render input, shadow

      w=input.columns+ shadow[:blur] *4+shadow[:left].abs*2
      h=input.rows+ shadow[:blur]*4+shadow[:top].abs*2
     
      input.matte = true
      
      opacity_color = "rgb(#{shadow[:opacity]},#{shadow[:opacity]},#{shadow[:opacity]})"
      input_colorized= input.copy.colorize(1.0, 1.0, 1.0, opacity_color)
      
      shadow_mask = Magick::Image.new(w,h ){self.background_color = '#fff'}
      
      zero=[shadow[:left].abs+shadow[:blur],shadow[:top].abs+shadow[:blur]]
      
      shadow_mask.composite!(input_colorized, shadow[:blur], shadow[:blur], Magick::OverCompositeOp)

      shadow_mask.matte=true
      shadow_mask = shadow_mask.blur_image(shadow[:blur],shadow[:blur])
   
      output = Magick::Image.new(w,h){self.background_color = shadow[:color]}
      inverse_shadow_mask = shadow_mask.negate
      inverse_shadow_mask.matte = false

      output.matte = true
      output.composite!(inverse_shadow_mask, zero[0]+shadow[:left],zero[1]+shadow[:top], Magick::CopyOpacityCompositeOp)
      output.composite!(input, zero[0]+shadow[:blur],zero[1]+shadow[:blur], Magick::OverCompositeOp)

      return output.trim
    end


    def self.rotate_render input, angle
      input.matte = true
      input.rotate!(angle)
      return input
    end

=begin
    def guassian_blur_render input, radius
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

  



