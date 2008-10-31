require 'fileutils' 

here = File.dirname(__FILE__)
rails_root = defined?(RAILS_ROOT) ? RAILS_ROOT : "#{here}/../../.."

STDOUT.puts "*********"
STDOUT.puts "* Saucy *"
STDOUT.puts "*********"
STDOUT.puts "Copying Saucy assets to Rails public Directory"
FileUtils.cp_r "#{rails_root}/vendor/plugins/saucy/assets/saucy", "#{rails_root}/public"
STDOUT.puts "... done"
STDOUT.puts "* add `map.saucy` in the your routes.rb"
STDOUT.puts "* start server and visit http://localhost:3000/saucy/saucy.html to test it is working"