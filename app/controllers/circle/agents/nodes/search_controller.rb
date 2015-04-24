class Circle::Agents::Nodes::SearchController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  public
    def set_items
      keyword = params[:q][:keyword]

      category_ids = params[:q][:category_ids].select{ |id| id.present? }.map{ |id| id.to_i }
      location_ids = params[:q][:location_ids].select{ |id| id.present? }.map{ |id| id.to_i }

      q_keyword  = keyword.present? ? keyword.split(/[\s　]+/).uniq.compact.map { |q| { name: /\Q#{q}\E/ } } : {}
      q_category = category_ids.present? ? { category_ids: category_ids } : {}
      q_location = location_ids.present? ? { location_ids: location_ids } : {}

      @keyword    = keyword
      @categories = Circle::Node::Category.in(_id: category_ids)
      @locations  = Circle::Node::Location.in(_id: location_ids)

      @items = Circle::Node::Page.site(@cur_site).and_public.
        where(@cur_node.condition_hash).
        and(q_keyword).
        in(q_category).
        in(q_location).
        order_by(name: 1)
    end

    def index
    end

    def result
      set_items
      @items = @items.page(params[:page]).
        per(@cur_node.limit)
    end
end
