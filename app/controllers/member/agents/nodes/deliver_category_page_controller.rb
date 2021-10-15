class Member::Agents::Nodes::DeliverCategoryPageController < ApplicationController
  include Cms::NodeFilter::View
  include Pippi::LoginFilter
  include Cms::NodeFilter::ListView

  helper Cms::ListHelper

  private

  def pages
    @items = Cms::Page.public_list(site: @cur_site, node: @cur_node, date: @cur_date).
      where(@cur_member.deliver_category_conditions)
  end
end
