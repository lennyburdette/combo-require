Rails.application.routes.draw do
  get "/combo(/:version)" => "combo_require/combo#combo"
end