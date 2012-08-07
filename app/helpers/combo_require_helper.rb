require "combo-require/module_map"

module ComboRequireHelper
  
  def module_map(overrides={})
    map = Combo::ModuleMap.new
    map.add_sprockets_assets
    map.modules.deep_merge(overrides).to_json.html_safe
  end
  
end