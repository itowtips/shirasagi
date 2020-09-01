class Tourism::Agents::Nodes::MapController < ApplicationController
  include Cms::NodeFilter::View
  helper Cms::ListHelper

  def index
    @items = @cur_node.ordered_tourism_pages
    @items = Kaminari.paginate_array(@items.to_a).page(params[:page]).per(@cur_node.limit)

    page = params[:page].to_i

    offset = 1
    offset += (page - 1) * @cur_node.limit if page > 0

    @items.each_with_index do |item, number|
      facility = item.facility

      next if facility.blank?

      map_pages = ::Facility::Map.site(@cur_site).and_public.
        where(filename: /^#{::Regexp.escape(facility.filename)}\//, depth: facility.depth + 1).
        order_by(order: 1)

      map_pages.each do |map|

        points = []
        map.map_points.each_with_index do |point, i|
          points.push point

          image_ids = @cur_node.categories.pluck(:image_id)
          points[i][:image] = SS::File.in(id: image_ids).first.try(:url)
          points[i][:html] = view_context.render_marker_info(facility)
          points[i][:number] = (number + offset).to_s
        end
        map.map_points = points

        if @merged_map
          @merged_map.map_points += map.map_points
        else
          @merged_map = map
        end
      end
    end

    render_with_pagination @items
  end
end
