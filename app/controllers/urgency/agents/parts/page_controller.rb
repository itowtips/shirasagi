class Urgency::Agents::Parts::PageController < ApplicationController
  include Cms::PartFilter::View
  helper Cms::ListHelper

  def index
    date = Time.zone.now

    @items = Urgency::Page.site(@cur_site).and_public(@cur_date).
      where(@cur_part.condition_hash(cur_path: @cur_path)).
      where({ :start_visible_date.lte => date, :close_visible_date.gt => date }).
      order_by(@cur_part.sort_hash).
      limit(@cur_part.limit)
  end
end
