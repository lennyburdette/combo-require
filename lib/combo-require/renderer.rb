module ComboRequire
  class Renderer
  
    def initialize(paths)
      @paths = paths
    end
  
    def render
      last_modified = nil
      body = @paths.map do |path|
        file = ::Rails.application.assets[path]
        if file
          last_modified ||= file.mtime
          last_modified = [file.mtime, last_modified].max
          file.to_s
        elsif /\.handlebars$/ =~ path
          template(path)
        end
      end
    
      headers = { "Content-Type" => "application/javascript;charset=utf-8" }
      headers["Last-Modified"] = last_modified.utc.to_s if last_modified
    
      [headers, body.join("\n")]
    end
    
    protected
      def template(path)
        without_ext = File.basename(path, File.extname(path))
        context = ActionView::LookupContext.new ::Rails.application.paths["app/views"]
        full_path = context.find(without_ext, [], partial: true).inspect
        handlebars_template( without_ext, File.read(full_path) )
      end
      
      def handlebars_template(name, content)
        <<-HandlebarsTemplate
define("templates/#{name}", ["handlebars"], function (Handlebars) {
  var cache;
  
  return function (object) {
    if (! cache)
      cache = Handlebars.compile(#{content.inspect});

    if (object == null) {
      return cache;
    } else {
      return cache(object);
    }
  }
});
HandlebarsTemplate
      end
  
  end
end