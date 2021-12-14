class Pippi::Agents::Nodes::SkillJsonController < ApplicationController
  include Cms::NodeFilter::View

  def index
    raise "404" if params[:format] != "json"

    items = Cms::Page.public_list(site: @cur_site, node: @cur_node, date: @cur_date).
      order_by(@cur_node.sort_hash).
      limit(@cur_node.limit).
      to_a
    items = items.map do |item|
      {
        name: item.name,
        url: item.full_url,
        html: item.render_html,
        ssml: item.try(:ssml),
        created: item.created,
        updated: item.updated,
        released: item.released,
        first_released: item.first_released,
      }
    end
    render json: items
  end
end
