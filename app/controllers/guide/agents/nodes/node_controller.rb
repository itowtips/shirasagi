class Guide::Agents::Nodes::NodeController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  def index
    @items = Guide::Node::Guide.public_list(site: @cur_site, node: @cur_node, date: @cur_date).
      order_by(@cur_node.sort_hash).
      page(params[:page]).
      per(@cur_node.limit)
  end
end
