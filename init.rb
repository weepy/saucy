require "saucy"
ActionView::Base.send(:include, Saucy::SaucyHelper)

Saucy.cache_image_sizes

