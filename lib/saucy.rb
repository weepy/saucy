
module Saucy
  OUTPUT_DIR = "/saucy"
  ABS_OUTPUT_DIR = "#{RAILS_ROOT}/public/#{OUTPUT_DIR}"      
  
  def self.png_dimensions file
    IO.read(file)[0x10..0x18].unpack('NN')
  end

  def self.get_png_size filename
    size = Rails.cache.read("Saucy:" + filename)
      
    if(!size)
      size = Saucy.png_dimensions("#{RAILS_ROOT}/public" + filename)
      Rails.cache.write("Saucy:" + filename, size)
    end
    size
  end

  def self.cache_image_sizes 
    Dir.entries(ABS_OUTPUT_DIR).select {|f| f.match(/.png$/)}.each do |image|
       get_png_size("#{OUTPUT_DIR}/#{image}")
    end
  end
end

require "saucy_render"
require "saucy_helper"

