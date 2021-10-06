class Member::Agents::Nodes::DeliverAgePageController < ApplicationController
  include Cms::NodeFilter::View
  include Member::LoginFilter
  include Cms::NodeFilter::ListView

  helper Cms::ListHelper

  private

  def pages
    @deliver_age_ids = @cur_member.deliver_ages.pluck(:st_category_ids).flatten
    @deliver_age_cond = { category_ids: { "$in" => @deliver_age_ids } }

    Cms::Page.public_list(site: @cur_site, node: @cur_node, date: @cur_date).
      where(@deliver_age_cond)
  end
end
