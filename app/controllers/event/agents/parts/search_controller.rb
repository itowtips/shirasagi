class Event::Agents::Parts::SearchController < ApplicationController
  include Cms::PartFilter::View
  helper Event::EventHelper

  def index
    @categories = Cms::Node.site(@cur_site).where({:id.in => @cur_part.cate_ids}).sort(filename: 1)
    node = @cur_part.find_search_node
    if node
      facility_page_ids = Cms::Page.site(@cur_site).and_public(@cur_date).where(node.condition_hash).pluck(:facility_page_ids).flatten.compact
      @facility_options = Facility::Node::Page.in(id: facility_page_ids).map { |item| [ item.name, item.id ] }
    end
  end
end
