class Cms::Agents::Parts::SiteSearchHistoryController < ApplicationController
  include Cms::PartFilter::View

  def index
    @items = []
    @node = Cms::Node::SiteSearch.site(@cur_site).first
    token = cookies["_ss_site_search"]

    if token.present?
      @items = Cms::SiteSearch::History::Log.site(@cur_site).
        where(token: token).limit(6)
    end
  end
end
