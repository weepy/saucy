require 'fileutils' 

here = File.dirname(__FILE__)
rails_root = defined?(RAILS_ROOT) ? RAILS_ROOT : "#{here}/../../.."

STDOUT.puts "*********"
STDOUT.puts "* Saucy *"
STDOUT.puts "*********"
STDOUT.puts "Creating /public/saucy Directory"
FileUtils.mkdir "#{rails_root}/public/saucy"
STDOUT.puts "... done"
STDOUT.puts "See README for more information"

