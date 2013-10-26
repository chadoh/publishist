class ActionDispatch::Routing::RouteSet
  def url_for_with_host_fix(options)
    url_for_without_host_fix(options.merge(host: 'publishist.dev'))
  end
  alias_method_chain :url_for, :host_fix
end
