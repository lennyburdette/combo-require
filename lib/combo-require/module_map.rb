module ComboRequire
  class ModuleMap
    
    attr_reader :modules
    def initialize
      @modules = {}
    end
    
    def add(name, config)
      @modules[name] = config
    end
    alias :[]= :add 
    
    def add_from_javascript_file(file, basedir)
      File.new(file).lines.each do |line|
        matches = /^\s*define\((?<name>[^,]+),(?<deps>[^\]]+)/.match(line)
        if matches
          self[ matches["name"].strip.gsub('"', '') ] = {
            path: Pathname.new(file).relative_path_from(basedir).to_s,
            requires: matches["deps"].strip.gsub(/[\[\]"\s]+/, '').split(",")
          }
          break
        end
      end
    end
    
    def add_from_bundled_asset(path)
      content = Rails.application.assets[path].to_s
      matches = /^\s*define\((?<name>[^,]+),(?<deps>[^\]]+)/.match(content)
      if matches
        puts matches
        self[ matches["name"].strip.gsub('"', '') ] = {
          path: path,
          requires: matches["deps"].strip.gsub(/[\[\]"\s]+/, '').split(",")
        }
      end
    end
    
    def add_sprockets_assets
      Rails.application.assets.each_logical_path do |path|
        add_from_bundled_asset(path) if /\.js/ =~ path && ! (/min/ =~ path)
      end
    end
    
  end
end