require "combo-require/renderer"

module ComboRequire
  class ComboController < ApplicationController
    def combo
      files = params.except(:action, :controller).keys
      headers, body = ComboRequire::Renderer.new(files).render
      response.headers.merge! headers
      render text: body
    end
  end
end