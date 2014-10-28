module Circle::Agents::Nodes::Node
  class ViewController < ApplicationController
    include Cms::NodeFilter::View
    helper Cms::ListHelper

    public
      def index
        @items = Circle::Node::Page.site(@cur_site).public.
          where(@cur_node.condition_hash).
          order_by(@cur_node.sort_hash).
          page(params[:page]).
          per(@cur_node.limit)

        @items.empty? ? "" : render
      end
  end
end
