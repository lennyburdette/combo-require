require "combo-require/module_map"

module ComboRequireHelper
  
  def module_map(options={})
    overrides = options[:overrides] || {}
    ignore = [/min\.js/].concat(options[:ignore] || [])
    
    map = ComboRequire::ModuleMap.new
    map.add_sprockets_assets(ignore: ignore)
    map.add_handlebars_files(Rails.root.join("app", "templates"))
    map.modules.deep_merge(overrides).to_json.html_safe
  end
  
end