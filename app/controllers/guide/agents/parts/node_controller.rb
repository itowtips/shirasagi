class Guide::Agents::Parts::NodeController < ApplicationController
  include Cms::PartFilter::View
  helper Cms::ListHelper

  def index
    @items = Guide::Node::Guide.public_list(site: @cur_site, part: @cur_part, date: @cur_date).
      order_by(@cur_part.sort_hash).
      limit(@cur_part.limit)
  end
end
