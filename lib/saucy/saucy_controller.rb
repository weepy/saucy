module Saucy
  
  class SaucyController < ActionController::Base
    def index
      file = params[:id][0]
      saucy_image = "#{RAILS_ROOT}/public/saucy/images/#{file}.png"
      Saucy::RenderTTF.render(file)
      
      respond_to do |format|
        format.png do
          send_file saucy_image, :disposition => 'inline', :type => "image/png"
        end
      end
    end
    
	end
end
