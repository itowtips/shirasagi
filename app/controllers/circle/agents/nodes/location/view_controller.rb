module Circle::Agents::Nodes::Location
  class ViewController < ApplicationController
    include Cms::NodeFilter::View
    helper Cms::ListHelper

    public
      def index
        conditions = params[:cond]

        if conditions.present?
          cond = []
          cond << { filename: /^#{@cur_node.filename}\//, depth: @cur_node.depth + 1 }

          conditions.each do |url|
            node = Cms::Node.filename(url).first
            next unless node
            cond << { filename: /^#{node.filename}\//, depth: node.depth + 1 }
          end

          condition_hash = { '$or' => cond }
        else
          condition_hash = {}
        end

        @items = Circle::Node::Page.site(@cur_site).public.
          in(location_ids: @cur_node.id).
          where(condition).
          order_by(@cur_node.sort_hash).
          page(params[:page]).
          per(@cur_node.limit)

        @items.empty? ? "" : render
      end
  end
end
