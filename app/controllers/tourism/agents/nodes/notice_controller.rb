class Tourism::Agents::Nodes::NoticeController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  before_action :accept_cors_request, only: [:rss]
  before_action :set_facility

  def set_facility
    return if params[:facility].blank?
    @facility = ::Facility::Node::Page.site(@cur_site).find(params[:facility]) rescue nil
    raise "404" unless @facility
  end

  def pages
    items = Tourism::Notice.public_list(site: @cur_site, node: @cur_node, date: @cur_date)
    items = items.where(facility_id: @facility.id) if @facility
    items
  end

  def index
    @items = pages.
      order_by(@cur_node.sort_hash).
      page(params[:page]).
      per(@cur_node.limit)

    render_with_pagination @items
  end

  def rss
    @items = pages.
      order_by(released: -1).
      limit(@cur_node.limit)

    render_rss @cur_node, @items
  end
end
