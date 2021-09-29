class Member::Agents::Parts::BookmarkController < ApplicationController
  include Cms::PartFilter::View
  helper Cms::ListHelper

  def index
    if @cur_part.parent.try(:route) == "member/bookmark"
      @node = @cur_part.parent.becomes_with_route
    else
      @node = Member::Node::Bookmark.site(@cur_site).first
    end
  end
end
