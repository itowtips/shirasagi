module Map::MapHelper
  def map_enabled?(opts = {})
    return true if !SS.config.cms.enable_lgwan
    return false if opts[:mypage]
    opts[:preview] ? false : true
  end

  def default_map_api(opts = {})
    map_setting = opts[:site].map_setting rescue {}
    opts[:api] || map_setting[:api] || SS.config.map.api
  end

  def include_map_api(opts = {})
    return "" unless map_enabled?(opts)

    api = default_map_api(opts)

    if %w(openlayers open_street_map).include?(api)
      include_openlayers_api
    else
      include_googlemaps_api(opts)
    end
  end

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

  def render_map(selector, opts = {})
    return "" unless map_enabled?(opts)

    markers = opts[:markers]
    map_options = opts[:map] || {}
    s = []

    case default_map_api(opts)
    when 'openlayers'
      include_openlayers_api

      # set default values
      map_options[:readonly] = true
      map_options[:markers] = markers if markers.present?
      map_options[:layers] = SS.config.map.layers

      s << 'var canvas = $("' + selector + '")[0];'
      s << "var opts = #{map_options.to_json};"
      s << 'var map = new Openlayers_Map(canvas, opts);'
    when 'open_street_map'
      include_openlayers_api

      # set default values
      map_options[:readonly] = true
      map_options[:markers] = markers if markers.present?
      map_options[:layers] = SS.config.map.open_street_map

      s << 'var canvas = $("' + selector + '")[0];'
      s << "var opts = #{map_options.to_json};"
      s << 'var map = new Openlayers_Map(canvas, opts);'
    else
      include_googlemaps_api(opts)

      s << "Googlemaps_Map.load(\"" + selector + "\", #{map_options.to_json});"
      s << 'Googlemaps_Map.setMarkers(' + markers.to_json + ');' if markers.present?
    end

    jquery { s.join("\n").html_safe }
  end

  def render_map_form(selector, opts = {})
    return "" unless map_enabled?(opts)

    center = opts[:center] || SS.config.map.map_center
    max_point_form = opts[:max_point_form] || SS.config.map.map_max_point_form
    map_options = opts[:map] || {}
    s = []

    case default_map_api(opts)
    when 'openlayers'
      include_openlayers_api

      # set default values
      map_options[:readonly] = true
      map_options[:center] = center.reverse if center.present?
      map_options[:layers] = SS.config.map.layers
      map_options[:max_point_form] = max_point_form if max_point_form.present?

      # 初回アドオン表示後に地図を描画しないと、クリックした際にマーカーがずれてしまう
      s << 'SS_AddonTabs.findAddonView(".mod-map").one("ss:addonShown", function() {'
      s << '  var canvas = $("' + selector + '")[0];'
      s << "  var opts = #{map_options.to_json};"
      s << '  var map = new Openlayers_Map_Form(canvas, opts);'
      s << '});'
    when 'open_street_map'
      include_openlayers_api

      # set default values
      map_options[:readonly] = true
      map_options[:center] = center.reverse if center.present?
      map_options[:layers] = SS.config.map.open_street_map
      map_options[:max_point_form] = max_point_form if max_point_form.present?

      s << 'SS_AddonTabs.findAddonView(".mod-map").one("ss:addonShown", function() {'
      s << '  var canvas = $("' + selector + '")[0];'
      s << "  var opts = #{map_options.to_json};"
      s << '  var map = new Openlayers_Map_Form(canvas, opts);'
      s << '});'
    else
      include_googlemaps_api(opts)

      # 初回アドオン表示後に地図を描画しないと、ズームが 2 に初期設定されてしまう。
      s << 'SS_AddonTabs.findAddonView(".mod-map").one("ss:addonShown", function() {'
      s << "  Googlemaps_Map.center = #{center.to_json};" if center.present?
      s << "  Map_Form.maxPointForm = #{max_point_form.to_json};" if max_point_form.present?
      s << '  Googlemaps_Map.setForm(Map_Form);'
      s << "  Googlemaps_Map.load(#{selector.to_json}, #{map_options.to_json});"
      s << '  Googlemaps_Map.renderMarkers();'
      s << '  Googlemaps_Map.renderEvents();'
      s << '  SS_AddonTabs.findAddonView(".mod-map").on("ss:addonShown", function() {'
      s << '    Googlemaps_Map.resize();'
      s << '  });'
      s << '});'
    end

    jquery { s.join("\n").html_safe }
  end

  def render_facility_search_map(selector, opts = {})
    return "" unless map_enabled?(opts)

    center = opts[:center] || SS.config.map.map_center
    markers = opts[:markers]

    s = []
    case default_map_api(opts)
    when 'openlayers'
      include_openlayers_api

      s << 'var opts = {'
      s << '  readonly: true,'
      s << '  center:' + center.reverse.to_json + ',' if center.present?
      s << '  markers: ' + markers.to_json + ',' if markers.present?
      s << '  layers: ' + SS.config.map.layers.to_json + ','
      s << '};'
      s << 'Openlayers_Facility_Search.render("' + selector + '", opts);'
    when 'open_street_map'
      include_openlayers_api

      s << 'var opts = {'
      s << '  readonly: true,'
      s << '  center:' + center.reverse.to_json + ',' if center.present?
      s << '  markers: ' + markers.to_json + ',' if markers.present?
      s << '  layers: ' + SS.config.map.open_street_map.to_json + ','
      s << '};'
      s << 'Openlayers_Facility_Search.render("' + selector + '", opts);'
    else
      include_googlemaps_api(opts)

      s << 'Googlemaps_Map.center = ' + center.to_json + ';' if center.present?
      s << 'var opts = {'
      s << '  markers: ' + (markers.try(:to_json) || '[]') + ','
      s << '};'
      s << 'Facility_Search.render("' + selector + '", opts);'
    end

    jquery { s.join("\n").html_safe }
  end

  def render_member_photo_form_map(selector, opts = {})
    return "" unless map_enabled?(opts)

    center = opts[:center] || SS.config.map.map_center
    map_options = opts[:map] || {}

    s = []
    case default_map_api(opts)
    when 'openlayers'
      include_openlayers_api
      controller.javascript "/assets/js/exif-js.js"

      # set default values
      map_options[:readonly] = true
      map_options[:center] = center.reverse if center.present?
      map_options[:layers] = SS.config.map.layers

      s << 'var canvas = $("' + selector + '")[0];'
      s << "var opts = #{map_options.to_json};"
      s << 'var map = new Openlayers_Member_Photo_Form(canvas, opts);'
      s << 'map.setExifLatLng("#item_in_image");'
    when 'open_street_map'
      include_openlayers_api
      controller.javascript "/assets/js/exif-js.js"

      # set default values
      map_options[:readonly] = true
      map_options[:center] = center.reverse if center.present?
      map_options[:layers] = SS.config.map.open_street_map

      s << 'var canvas = $("' + selector + '")[0];'
      s << "var opts = #{map_options.to_json};"
      s << 'var map = new Openlayers_Member_Photo_Form(canvas, opts);'
      s << 'map.setExifLatLng("#item_in_image");'
    else
      include_googlemaps_api(opts)
      controller.javascript "/assets/js/exif-js.js"

      s << 'Googlemaps_Map.center = ' + center.to_json + ';' if center.present?
      s << 'Googlemaps_Map.setForm(Member_Photo_Form);'
      s << "Googlemaps_Map.load(\"" + selector + "\", #{map_options.to_json});"
      s << 'Googlemaps_Map.renderMarkers();'
      s << 'Googlemaps_Map.renderEvents();'
      s << 'Member_Photo_Form.setExifLatLng("#item_in_image");'
    end

    jquery { s.join("\n").html_safe }
  end

  def render_marker_info(item)
    h = []
    h << %(<div class="maker-info" data-id="#{item.id}">)
    h << %(<p class="name">#{item.name}</p>)
    h << %(<p class="address">#{item.address}</p>)
    h << %(<p class="show">#{link_to t('ss.links.show'), item.url}</p>)
    h << %(</div>)
  end

  def map_point_info(event, map_point)
    url = "https://www.google.co.jp/maps/search/" + map_point[:loc].join(',')
    h = []
    h << %(<div class="maker-info">)
    h << %(<p class="name">#{map_point[:name]}</p>)
    h << %(<p class="text">#{map_point[:text]}</p>)
    h << %(<p class="map-url"><a href="#{url}">#{I18n.t('map.googlemap_url')}</a></p>)
    h << %(</div>)
    h << %(<div class="event-info">イベント情報(1#{t("event.count")}))
    h << %(<div class="event-list">)
    h << %(<div>)
    h << %(<p class="event-name">#{link_to event.name, event.url}</p>)
    h << %(<p class="event-dates">#{raw event.dates_to_html(:long)}</p>)
    h << %(</div>)
    h << %(</div>)
    h << %(</div>)
    h.join("\n")
  end

  def render_map_point_info(event, map_point)
    if event_end_date(event).present?
      if @items.present?
        if event_end_date(event) >= Time.zone.today || @items.where(id: event.id).present?
          map_point_info(event, map_point)
        end
      elsif event_end_date(event) >= Time.zone.today
        map_point_info(event, map_point)
      end
    end
  end

  def render_facility_info(item, map_point)
    h = render_marker_info(item)
    url = "https://www.google.co.jp/maps/search/" + map_point.join(',')
    h << %(<p class="map-url"><a href="#{url}">#{I18n.t('map.googlemap_url')}</a></p>)
    events = Event::Page.site(@cur_site).and_public.where(facility_ids: item.id).order(event_dates: "ASC")
    if events.present?
      event_count = 0
      events.each do |event|
        if event_end_date(event).present?
          if @items.present?
            next if event_end_date(event) <= Time.zone.today && @items.where(id: event.id).blank?
          elsif event_end_date(event) <= Time.zone.today
            next
          end
          next if event.map_points.present? && event.facility_ids.present?
          event_count += 1
        end
      end
      if event_count != 0
        h << %(<div class="event-info">イベント情報(#{event_count}#{t("event.count")}))
        h << %(<div class="event-list">)
        events.each do |event|
          next if event.map_points.present? && event.facility_ids.present?
          if event_end_date(event).present?
            if @items.present?
              next if event_end_date(event) <= Time.zone.today && @items.where(id: event.id).blank?
            elsif event_end_date(event) <= Time.zone.today
              next
            end
            h << %(<div>)
            h << %(<p class="event-name">#{link_to event.name, event.url}</p>)
            h << %(<p class="event-dates">#{raw event.dates_to_html(:long)}</p>)
            h << %(</div>)
          end
        end
        h << %(</div>)
        h << %(</div>)
      end
    end
    h.join("\n")
  end

  def monthly_map_point_info(event, map_point)
    map_point_info(event, map_point)
  end

  def monthly_facility_info(item, dates, map_point)
    h = render_marker_info(item)
    url = "https://www.google.co.jp/maps/search/" + map_point.join(',')
    h << %(<p class="map-url"><a href="#{url}">#{I18n.t('map.googlemap_url')}</a></p>)
    events = Event::Page.site(@cur_site).and_public.where(facility_ids: item.id)
    if events.present?
      events = events.where(:event_dates.in => dates).
        entries.
        sort_by { |page| page.event_dates }
      event_count = 0
      events.each do |event|
        next if event.map_points.present? && event.facility_ids.present?
        event_count += 1
      end
      if event_count != 0
        h << %(<div class="event-info">イベント情報(#{event_count}#{t("event.count")}))
        h << %(<div class="event-list">)
        events.each do |event|
          next if event.map_points.present? && event.facility_ids.present?
          h << %(<div>)
          h << %(<p class="event-name">#{link_to event.name, event.url}</p>)
          h << %(<p class="event-dates">#{raw event.dates_to_html(:long)}</p>)
          h << %(</div>)
        end
        h << %(</div>)
        h << %(</div>)
      end
    end
    h.join("\n")
  end

  def render_event_info(item, map_point)
    h = []
    url = "https://www.google.co.jp/maps/search/" + map_point[:loc].join(',')
    if map_point[:name].present? || map_point[:text].present?
      h << %(<div class="maker-info">)
      h << %(<p class="name">#{map_point[:name]}</p>)
      h << %(<p class="text">#{map_point[:text]}</p>)
      h << %(<p class="map-url"><a href="#{url}">#{I18n.t('map.googlemap_url')}</a></p>)
      h << %(</div>)
    end
    events = Event::Page.site(@cur_site).and_public.where(facility_ids: item.id).order(event_dates: "ASC")
    if events.present?
      event_count = 0
      events.each do |event|
        if event_end_date(event).present?
          next if event_end_date(event) <= Time.zone.today
          next if event.map_points.present? && event.facility_ids.present?
          event_count += 1
        end
      end
      if event_count != 0
        h << %(<div class="event-info">イベント情報(#{event_count}#{t("event.count")}))
        h << %(<div class="event-list">)
        events.each do |event|
          next if event.map_points.present? && event.facility_ids.present?
          if event_end_date(event).present?
            next if event_end_date(event) <= Time.zone.today
            h << %(<div>)
            h << %(<p class="event-name">#{link_to event.name, event.url}</p>)
            h << %(<p class="event-dates">#{raw event.dates_to_html(:long)}</p>)
            h << %(</div>)
          end
        end
        h << %(</div>)
        h << %(</div>)
      end
    end
    h.join("\n")
  end

  def event_end_date(event)
    event_dates = event.get_event_dates
    return if event_dates.blank?

    event_range = event_dates.first

    if event_dates.length == 1
      end_date = ::Icalendar::Values::Date.new(event_range.last.tomorrow.to_date)
    else # event_dates.length > 1
      dates = event_dates.flatten.uniq.sort
      event_range = ::Icalendar::Values::Array.new(dates, ::Icalendar::Values::Date, {}, { delimiter: "," })
      end_date = ::Icalendar::Values::Date.new(event_range.last.tomorrow.to_date)
    end
    end_date
  end
end
