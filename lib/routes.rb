with_options :controller => "saucy/saucy" do |map|
  map.connect 'saucy/images/*id.png', :action => "index"
end