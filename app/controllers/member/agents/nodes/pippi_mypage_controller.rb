class Member::Agents::Nodes::PippiMypageController < ApplicationController
  include Cms::NodeFilter::View
  include Pippi::LoginFilter
  include Cms::NodeFilter::ListView

  def index
    @item = @cur_member

    @profile_node = Member::Node::PippiProfile.site(@cur_site).first
    @bookmark_node = Member::Node::Bookmark.site(@cur_site).first

    @deliver_category_nodes = @cur_node.children.where(route: "member/deliver_category_page").order_by(order: 1).to_a
    @deliver_category_nodes = @deliver_category_nodes.map(&:becomes_with_route)

    @deliver_age_nodes = @cur_node.children.where(route: "member/deliver_age_page").order_by(order: 1).to_a
    @deliver_age_nodes = @deliver_age_nodes.map(&:becomes_with_route)

    @cur_member.squish_bookmarks
    @bookmarks = @cur_member.bookmarks.and_public.limit(10)

    # member
    @deliver_category_ids = @cur_member.deliver_categories.pluck(:st_category_ids).flatten
    @deliver_category_cond = { category_ids: { "$in" => @deliver_category_ids } }

    @deliver_age_ids = @cur_member.deliver_ages.pluck(:st_category_ids).flatten
    @deliver_age_cond = { category_ids: { "$in" => @deliver_age_ids } }
  end
end
