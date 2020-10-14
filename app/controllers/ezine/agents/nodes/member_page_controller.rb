class Ezine::Agents::Nodes::MemberPageController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  private

  def pages
    pages = Ezine::Page.public_list(site: @cur_site, node: @cur_node, date: @cur_date)
    @lang = @cur_site.translate_targets.select{ |target| target.code == params[:lang] }.first || @cur_site.translate_source
    if @lang.present?
      pages = pages.where(translate_target_ids: @lang.id)
    end
    pages
  end

  public

  def index
    @items = pages.
      order_by(@cur_node.sort_hash).
      page(params[:page]).
      per(@cur_node.limit)

    render_with_pagination @items
  end
end
