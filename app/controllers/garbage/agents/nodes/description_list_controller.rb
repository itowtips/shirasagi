class Garbage::Agents::Nodes::DescriptionListController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  def index
    @items = Garbage::Node::Description.site(@cur_site).and_public.
      where(@cur_node.condition_hash).
      order_by(@cur_node.sort_hash).
      page(params[:page]).
      per(@cur_node.limit)
  end
end