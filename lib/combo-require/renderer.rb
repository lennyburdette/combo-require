module ComboRequire
  class Renderer
  
    def initialize(paths)
      @paths = paths
    end
  
    def render
      last_modified = nil
      body = @paths.map do |path|
        file = ::Rails.application.assets[path]
        last_modified ||= file.mtime
        last_modified = [file.mtime, last_modified].max
        file.to_s
      end
    
      headers = {
        "Content-Type" => "application/javascript;charset=utf-8",
        "Last-Modified" => last_modified.utc.to_s
      }
    
      [headers, body.join("\n")]
    end
  
  end
end