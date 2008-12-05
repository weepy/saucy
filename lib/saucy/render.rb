require 'rvg/rvg'
require 'fileutils'

module Saucy
  class Render
    FONT_STORE = File.join(File.dirname(__FILE__), *%w[ .. .. fonts ])
    
    DEFAULT_STYLE = { 
      :background => "transparent",
      :font       => {
        :size     => 18, 
        :color    => "#000", 
        :font     => "arial", 
        :stretch  => "normal"
      },
      :stroke => {
        :width    => 0, 
        :color    => "#000", 
        :inner    => true 
      },
      :spacing    => {
        :letter   => 0, 
        :word     => 0
      },
      :rotate => 0,
      :shadow => {
        :color => "#000", 
        :opacity => 0.6, 
        :top => 2, 
        :left => 2, 
        :blur => 5.0, 
        :render => false 
      }
    }
    
    class << self
      def render(name, filename, options = {})
        style = DEFAULT_STYLE.deep_merge(options[:style] || {})    
        
        image = draw(name,  
                     style[:font], 
                     style[:background], 
                     style[:stroke],
                     style[:spacing],
                     style[:shadow],
                     style[:rotate]
                  )
                  

        if options[:highlight]
          images  = Magick::ImageList.new
          style   = style.deep_merge(options[:highlight])
          
          images << draw(name,  
                      style[:font], 
                      style[:background], 
                      style[:stroke],
                      style[:spacing],
                      style[:shadow],
                      style[:rotate]
                    )
          images << image

          # Append vertically
          image = images.append(true)
        end
        
        # Make saucy dir
        FileUtils.mkdir_p(ABS_OUTPUT_DIR)
        
        image.write(File.join(ABS_OUTPUT_DIR, filename))
      end
    
      def draw(text, font, background, stroke, spacing, shadow, rotate)
        lines = text.split("\n")

        width = font[:size] * text.length + stroke[:width] * 2
        height = (font[:size] * 2 + stroke[:width] * 2) * lines.length
      
        rvg = Magick::RVG.new(width, height) do |canvas|
          canvas.background_fill = background if background != 'transparent'
        
          sw = stroke[:width]
        
          font_file = font[:font].match(/\./) ? File.join(FONT_STORE, font[:font]) : font[:font]

          styles = {
            :font             =>  font_file.inspect,
            :font_size        =>  font[:size], 
            :fill             =>  font[:color], 
            :font_stretch     =>  font[:stretch],
            :letter_spacing   =>  spacing[:letter],
            :word_spacing     =>  spacing[:word],
            :glyph_orientation_horizontal => font[:rotate]
          }
        
          if stroke[:width] > 0
            styles.merge!(:stroke => stroke[:color], :stroke_width => stroke[:width])
      	  end
        
          line_height = font[:height] || font[:size]
          y = 0

          lines.each do |line|
            canvas.text(sw,font[:size] + y, line).styles(styles)

            if stroke[:inner] && stroke[:width] > 1
              inner = styles.merge(:stroke_width => 1, :stroke => font[:color])
              canvas.text(sw,font[:size] + y, line).styles(inner)
            end
            y += line_height
          end
        end
      
        image = rvg.draw.trim
        
        if rotate != 0
          image = rotate!(image, rotate) 
        end
        
        if shadow[:render]
          image = shadow!(image, shadow)
        end

        image.trim        
      end
      
      def shadow! input, shadow

        w=input.columns+ shadow[:blur] *4+shadow[:left].abs*2
        h=input.rows+ shadow[:blur]*4+shadow[:top].abs*2

        input.matte = true
        opacity = (shadow[:opacity]*255).to_i
        opacity_color = "rgb(#{opacity},#{opacity},#{opacity})"
        
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

        output
      end


      def rotate! input, angle
        input.matte = true
        input.rotate!(angle)
        input
      end
      
    end # self
  end
end