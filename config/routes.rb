Rails.application.routes.draw do
  get "/combo(/:version)" => "combo_require_controller#combo"
end