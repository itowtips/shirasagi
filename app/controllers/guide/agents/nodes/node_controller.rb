class Guide::Agents::Nodes::NodeController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  def index
    @items = Guide::Node::Guide.site(@cur_site).and_public.
      where(@cur_node.condition_hash).
      order_by(@cur_node.sort_hash).
      page(params[:page]).
      per(@cur_node.limit)
  end
end
