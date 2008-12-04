module Saucy
  class Image
    class << self
      
      def size(filename)
        path  = File.join(ABS_OUTPUT_DIR, filename)
        image = Magick::Image::read(path).first
        [image.columns, image.rows]
      end

      def cached_size(filename)
        sz = Rails.cache.read("saucy:" + filename)
        unless sz
          sz = size(filename)
          Rails.cache.write("saucy:" + filename, sz)
        end
        sz
      end
      
    end
  end
end