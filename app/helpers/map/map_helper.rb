module Map::MapHelper
  def include_googlemaps_api(opts = {})
    map_setting = opts[:site].map_setting rescue {}

    key = opts[:api_key] || map_setting[:api_key] || SS.config.map.api_key
    language = opts[:language] || SS.config.map.language
    region = opts[:region] || SS.config.map.region

    params = {}
    params[:v] = 3
    params[:key] = key if key.present?
    params[:language] = language if language.present?
    params[:region] = region if region.present?
    controller.javascript "//maps.googleapis.com/maps/api/js?#{params.to_query}"
  end

  def include_openlayers_api
    controller.javascript "/assets/js/openlayers/ol.js"
    controller.stylesheet "/assets/js/openlayers/ol.css"
  end

  def include_ol3_google_maps_api
    controller.javascript "/assets/js/ol3-google-maps/ol3gm.js"
    #controller.javascript "/assets/js/ol3-google-maps/ol3gm-debug.js"
    controller.stylesheet "/assets/js/ol3-google-maps/ol3gm.css"
  end

  def render_map(selector, opts = {})
    map_setting = opts[:site].map_setting rescue {}

    api = opts[:api] || map_setting[:api] || SS.config.map.api
    #center = opts[:center]
    markers = opts[:markers]

    if api == "openlayers"
      include_openlayers_api

      s = []
      s << 'var canvas = $("' + selector + '")[0];'
      s << 'var opts = {'
      s << '  readonly: true,'
      s << '  markers: ' + markers.to_json + ',' if markers.present?
      s << '  layers: ' + SS.config.map.layers.to_json + ','
      s << '};'
      s << 'var map = new Openlayers_Map(canvas, opts);'
    else
      include_googlemaps_api(opts)

      s = []
      s << 'Map.load("' + selector + '");'
      s << 'Map.setMarkers(' + markers.to_json + ');' if markers.present?
    end

    jquery { s.join("\n").html_safe }
  end

  def render_map_form(selector, opts = {})
    map_setting = opts[:site].map_setting rescue {}

    api = opts[:api] || map_setting[:api] || SS.config.map.api
    center = opts[:center] || SS.config.map.map_center
    max_point_form = opts[:max_point_form] || SS.config.map.map_max_point_form
    #markers = opts[:markers]

    if api == "openlayers"
      include_openlayers_api

      s = []
      s << 'var canvas = $("' + selector + '")[0];'
      s << 'var opts = {'
      s << '  readonly: true,'
      s << '  center:' + center.to_json + ',' if center.present?
      s << '  layers: ' + SS.config.map.layers.to_json + ','
      s << '  max_point_form: ' + max_point_form.to_json + ',' if max_point_form.present?
      s << '};'
      s << 'var map = new Openlayers_Map_Form(canvas, opts);'
      s << 'SS_AddonTabs.hide(".mod-map");'
    else
      include_googlemaps_api(opts)

      s = []
      s << 'SS_AddonTabs.hide(".mod-map");'
      s << 'Map.center = ' + center.reverse.to_json + ';' if center.present?
      s << 'Map_Form.maxPointForm = ' + max_point_form.to_json + ';' if max_point_form.present?
      s << 'Map.setForm(Map_Form);'
      s << 'Map.load("' + selector + '");'
      s << 'Map.renderMarkers();'
      s << 'Map.renderEvents();'
      s << 'SS_AddonTabs.head(".mod-map").click(function() { Map.resize(); });'
    end

    jquery { s.join("\n").html_safe }
  end

  def render_facility_search_map(selector, opts = {})
    map_setting = opts[:site].map_setting rescue {}

    api = opts[:api] || map_setting[:api] || SS.config.map.api
    center = opts[:center] || SS.config.map.map_center
    markers = opts[:markers]

    s = []
    if api == "openlayers"
      include_openlayers_api

      s << 'var opts = {'
      s << '  readonly: true,'
      s << '  center:' + center.to_json + ',' if center.present?
      s << '  markers: ' + markers.to_json + ',' if markers.present?
      s << '  layers: ' + SS.config.map.layers.to_json + ','
      s << '};'
      s << 'Openlayers_Facility_Search.render("' + selector + '", opts);'
    else
      include_googlemaps_api(opts)

      s << 'Map.center = ' + center.reverse.to_json + ';' if center.present?
      s << 'var opts = {'
      s << '  markers: ' + markers.to_json + ',' if markers.present?
      s << '};'
      s << 'Facility_Search.render("' + selector + '", opts);'
    end

    jquery { s.join("\n").html_safe }
  end

  def render_facility_geolocation(selector, opts = {})
    map_setting = opts[:site].map_setting rescue {}

    api = opts[:api] || map_setting[:api] || SS.config.map.api
    center = opts[:center] || SS.config.map.map_center
    markers = opts[:markers]
    loc = opts[:loc]
    radius = opts[:radius]
    layer = opts[:layer]

    s = []
    if api == "openlayers"
      include_googlemaps_api(opts)
      include_openlayers_api
      include_ol3_google_maps_api

      s << 'window.opts = {'
      s << '  readonly: true,'
      s << '  center:' + center.to_json + ',' if center.present?
      s << '  markers: ' + markers.to_json + ',' if markers.present?
      s << '  layers: ' + SS.config.map.layers.to_json + ','
      s << '  loc: ' + loc.to_json + ',' if loc.present?
      s << '  radius: ' + radius.to_json + ',' if radius.present?
      s << '  defaultLayer: ' + layer.to_json + ',' if layer.present?
      s << '};'
      s << 'Openlayers_Facility_Geolocation.render("' + selector + '", opts);'
      #s << 'window.onload = function() {'
      #s << '  Openlayers_Facility_Geolocation.render("' + selector + '", opts);'
      #s << '}'
    else
      include_googlemaps_api(opts)

      s << 'Geolocation_Map.center = ' + center.reverse.to_json + ';' if center.present?
      s << 'var opts = {'
      s << '  markers: ' + markers.to_json + ',' if markers.present?
      s << '  loc: ' + loc.to_json + ',' if loc.present?
      s << '  radius: ' + radius.to_json + ',' if radius.present?
      s << '  defaultLayer: ' + layer.to_json + ',' if layer.present?
      s << '};'
      s << 'Facility_Geolocation.render("' + selector + '", opts);'
    end

    jquery { s.join("\n").html_safe }
  end

  def render_member_photo_form_map(selector, opts = {})
    map_setting = opts[:site].map_setting rescue {}

    api = opts[:api] || map_setting[:api] || SS.config.map.api
    center = opts[:center] || SS.config.map.map_center

    s = []
    if api == "openlayers"
      include_openlayers_api
      controller.javascript "/assets/js/exif-js.js"

      s = []
      s << 'var canvas = $("' + selector + '")[0];'
      s << 'var opts = {'
      s << '  readonly: true,'
      s << '  center:' + center.to_json + ',' if center.present?
      s << '  layers: ' + SS.config.map.layers.to_json + ','
      s << '};'
      s << 'var map = new Openlayers_Member_Photo_Form(canvas, opts);'
      s << 'map.setExifLatLng("#item_in_image");'
    else
      include_googlemaps_api(opts)
      controller.javascript "/assets/js/exif-js.js"

      s << 'Map.center = ' + center.reverse.to_json + ';' if center.present?
      s << 'Map.setForm(Member_Photo_Form);'
      s << 'Map.load("' + selector + '");'
      s << 'Map.renderMarkers();'
      s << 'Map.renderEvents();'
      s << 'Member_Photo_Form.setExifLatLng("#item_in_image");'
    end

    jquery { s.join("\n").html_safe }
  end

  def render_marker_info(item)
    h = []

    image_pages = item.image_pages.and_public.order_by(order: 1).to_a
    image_page = image_pages.select { |page| page.image.present? }.first
    h << %(<div class="maker-info" data-id="#{item.id}">)
    h << %(<p class="name"><a href="#{item.url}">#{item.name}</a></p>)
    h << %(<img src="#{image_page.image.thumb_url}" alt="#{item.name}">) if image_page
    h << %(<p class="address">#{item.address}</p>)
    h << %(</div>)

    h.join("\n")
  end

  def render_marker_info_include_directions(item, points)
    h = []
    dump points
    loc = points.first["loc"] rescue nil
    url = "http://maps.google.com/maps?daddr=#{item.address}"
    url = "http://maps.google.com/maps?daddr=#{loc.values.join(",")}" if loc

    image_pages = item.image_pages.and_public.order_by(order: 1).to_a
    image_page = image_pages.select { |page| page.image.present? }.first
    h << %(<div class="maker-info" data-id="#{item.id}">)
    h << %(<p class="name"><a href="#{item.url}">#{item.name}</a></p>)
    h << %(<img src="#{image_page.image.thumb_url}" alt="#{item.name}">) if image_page
    h << %(<p class="address">#{item.address}</p>)
    h << %(<p class="show"><a href="#{url}" target="_blank">経路案内(Googleで表示)</a></p>)
    h << %(</div>)

    h.join("\n")
  end

  def render_map_sidebar(item)
    h = []

    h << %(<div class="column" data-id="#{item.id}">)
    h << %(<p><a href="#{item.url}">#{item.name}</a></p>)
    h << %(<p>#{item.address}</p>)
    h << %(<p><a href="#" class="click-marker">#{I18n.t("facility.sidebar.click_marker")}</a></p>)
    h << %(</div>)

    h.join("\n")
  end
end
