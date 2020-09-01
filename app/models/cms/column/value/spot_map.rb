class Cms::Column::Value::SpotMap < Cms::Column::Value::Base
  liquidize do
    export :value
  end

  def value
    "施設の地図が表示されます。"
  end

  def _to_html(options = {})
    page = _parent
    return "" if page.blank?

    facility = page.facility
    site = page.site

    return "" if facility.blank? || site.blank?

    map_pages = ::Facility::Map.site(site).and_public.
      where(filename: /^#{::Regexp.escape(facility.filename)}\//, depth: facility.depth + 1).
      order_by(order: 1).to_a

    return "" if map_pages.blank?

    helpers = ::Tourism::Agents::Pages::PageController.helpers
    helpers.instance_variable_set :@cur_site, site

    merged_map = nil
    map_pages.each do |map|
      points = []
      map.map_points.each_with_index do |point, i|
        points.push point

        image_ids = facility.categories.pluck(:image_id)
        points[i][:image] = SS::File.in(id: image_ids).first.try(:url)
        points[i][:html] = helpers.render_event_info(facility, point)
      end
      map.map_points = points

      if merged_map
        merged_map.map_points += map.map_points
      else
        merged_map = map
      end
    end

    h = []
    #h << helpers.render_map("#map-canvas", markers: merged_map.map_points, site: site, map: { zoom: merged_map.map_zoom_level })
    h << '<div id="map-canvas" style="width: 100%; height: 400px;"></div>'
    h.join("\n")
  end
end
