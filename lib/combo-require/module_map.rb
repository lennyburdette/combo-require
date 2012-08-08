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
        matches = /^\s*(\(function\(\)\{)*define\((?<name>[^,\[]+),(?<deps>[^\]]+)/.match(line)
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
      content = ::Rails.application.assets[path].to_s
      matches = /^\s*(\(function\(\)\{)*define\((?<name>[^,\[]+),(?<deps>[^\]]+)/.match(content)
      if matches
        self[ matches["name"].strip.gsub('"', '') ] = {
          path: path,
          requires: matches["deps"].strip.gsub(/[\[\]"\s]+/, '').split(",")
        }
      end
    end
    
    def add_sprockets_assets(options={})
      puts options[:ignore]
      ::Rails.application.assets.each_logical_path do |path|
        if /\.js/ =~ path
          should_ignore = options[:ignore].map { |pattern| ! pattern.match(path).nil? } if options[:ignore]
          add_from_bundled_asset(path) unless should_ignore.try(:include?, true)
        end
      end
    end
    
    def add_handlebars_files(directory)
      Dir[ File.join(directory, "**/*.handlebars") ].each do |file|
        without_ext = File.basename(file, File.extname(file)).sub(/^_/, '')
        self[ "templates/#{without_ext}" ] = {
          path: "#{without_ext}.handlebars",
          requires: ["handlebars"]
        }
      end
    end
    
  end
end