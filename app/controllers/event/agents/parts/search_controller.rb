class Event::Agents::Parts::SearchController < ApplicationController
  include Cms::PartFilter::View
  helper Event::EventHelper

  def index
    @categories = Cms::Node.site(@cur_site).where({:id.in => @cur_part.cate_ids}).sort(filename: 1)
    @facilities = Facility::Node::Page.site(@cur_site).and_public
  end
end
