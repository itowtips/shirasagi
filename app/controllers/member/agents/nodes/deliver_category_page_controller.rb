class Member::Agents::Nodes::DeliverCategoryPageController < ApplicationController
  include Cms::NodeFilter::View
  include Pippi::LoginFilter
  include Cms::NodeFilter::ListView

  helper Cms::ListHelper

  private

  def pages
    @deliver_category_ids = @cur_member.deliver_categories.pluck(:st_category_ids).flatten
    @deliver_category_cond = { category_ids: { "$in" => @deliver_category_ids } }

    Cms::Page.public_list(site: @cur_site, node: @cur_node, date: @cur_date).
      where(@deliver_category_cond)
  end
end
