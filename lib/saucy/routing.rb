module Saucy
  module Routing
    def saucy(opts={})
      path = File.join(File.dirname(File.expand_path(__FILE__)), "..", "routes.rb")
      @root = opts[:root] || "saucy"
      eval(IO.read(path))
    end
  end
end
