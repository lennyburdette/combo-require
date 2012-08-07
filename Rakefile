require "bundler/gem_tasks"

# Monkey patch Bundler gem_helper so we release to our gem server instead of rubygems.org
GEM_SERVER_URL = "http://gemserver:Zappos101@gems.zappos-expo.com"

module Bundler
  class GemHelper
    def rubygem_push(path)
      sh("gem inabox '#{path}' --host #{GEM_SERVER_URL}")
      Bundler.ui.confirm "Pushed #{name} #{version} to #{GEM_SERVER_URL}"     
    end
  end
end