class Member::Agents::Parts::FavoritePageController < ApplicationController
  include Cms::PartFilter::View
  helper Cms::ListHelper

  def index
    @node = Member::Node::FavoritePage.site(@cur_site).first
    raise "404" unless @node
  end
end
