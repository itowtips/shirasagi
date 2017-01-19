module JobDb::NodeHelper
  def contents_path(node)
    route = node.view_route.present? ? node.view_route : node.route
    "/.s#{node.site.id}/" + route.pluralize.sub("/", "#{node.id}/")
  rescue StandardError => e
    raise(e) unless Rails.env.production?
    node_nodes_path(site: node.site, cid: node)
  end
end
