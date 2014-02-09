# encoding: utf-8

module HelperBase
  def logger
    API.logger
  end

  def render_custom(root_name, template, object, status)
    data = Rabl::Renderer.new(template, object, {:format => 'hash'}).render
    { root_name => data }
  end
end
