module Saucy
  module Helper
    
    # Arguments:
    # saucy_tag(name, :option1 => 'foo')
    # saucy_tag(name1, :option2 => 'foo', :hover => {:font => {:color => 'blue'}})
    
    def saucy_tag(name, options = {}, &block)      
      filename  = Digest::MD5.hexdigest(name + options.to_s) + '_' + name.gsub(/[^a-z0-9]+/i, '_') + '.png'
      
      #unless File.exists?(File.join(ABS_OUTPUT_DIR, filename))
        Saucy::Render.render(name, filename, options)
      #end
      
      size = Saucy::Image.cached_size(filename)
      # We divide by the number of images to get the height
      # of the first one (for sprites)
      real_height = size[1] / (options[:hover] ? 2 : 1)
      
      src  = File.join(OUTPUT_DIR, filename)
      
      options[:html] ||= {}
      options[:html][:class] ||= []
      style = options[:html][:style] ||= {}
      
      style['text-indent'] = '-5000px'
      #style['color'] = 'transparent' #alternative (allows selecting of the text)
      style['background'] = "url('#{src}') 0 -#{size[1] - real_height}px no-repeat"

      style['width']      = "#{size[0]}px"
      style['height']     = "#{real_height}px"

      style['overflow'] = "hidden"
      style['display'] = "block"
            
      if options[:transparent]
        style['_background']    = 'transparent';
        style['_filter:progid'] = "DXImageTransform.Microsoft.AlphaImageLoader(src='#{src}', sizingMethod='crop')"
      end
      
      options[:html][:class] << 'saucy'
      if options[:hover]
        options[:html][:class] << 'saucySprite'
      end
      
      options[:tag] ||= :p
      
      # need to use a's for tags for automaitc :hover support (IE6)
      
      options[:html][:style] = style.collect {|key, value| [key, value].join(':') }.join(';')
      options[:html][:class] = options[:html][:class].join(' ')
      options[:html].delete(:class) if options[:html][:class].blank?

      
      if block_given?
        concat(content_tag(options[:tag] || :a, capture(&block), options[:html] || {}))
      else
        content_tag(options[:tag] || :a, name, options[:html] || {})
      end
      
    end

  end
end
