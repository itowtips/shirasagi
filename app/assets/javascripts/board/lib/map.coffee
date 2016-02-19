//= require 'openlayers/ol'

# Used Openlayers 3
# Document: http://openlayers.org/en/v3.12.1/apidoc/
# Sample: http://maps.gsi.go.jp/development/sample.html
class @Board_Map
  constructor: (canvas, opts = {}) ->
    @canvas = canvas
    @opts = opts
    @handlers = {}
    @markerFeature = null
    @markerLayer = null
    @popup = null
    @render()

  render: () ->
    center = @opts['center'] || @opts['marker'] || [138.252924,36.204824]

    @map = new ol.Map
      target: @canvas
      renderer: ['canvas', 'dom']
      layers: [
        new ol.layer.Tile
          source: new ol.source.XYZ
            attributions: [],
            url: "http://cyberjapandata.gsi.go.jp/xyz/std/{z}/{x}/{y}.png"
            projection: "EPSG:3857"
      ],
      controls: ol.control.defaults
        attributionOptions:
          collapsible: false
      view: new ol.View
        projection: "EPSG:3857"
        center: ol.proj.transform(center, "EPSG:4326", "EPSG:3857")
        maxZoom: 18
        zoom: @opts['zoom'] || 10

    if @opts['gps']
      @setMarkerFromGps()

    if @opts['marker']
      @setMarker(@opts['marker'])

    if !@opts['readonly']
      @map.on 'click', (e) =>
        pos = ol.proj.transform(e.coordinate, "EPSG:3857", "EPSG:4326")
        @setMarker(pos)

  setMarker: (position) ->
    if !@markerFeature
      src = '/assets/img/map-marker.png'
      src = @opts['image'] if @opts['image']

      style = new ol.style.Style({
        image: new ol.style.Circle({
          radius: 8
          stroke: new ol.style.Stroke({
            color: 'rgba(244,67,54,0.8)'
            width: 8
          })
        })
      })

      @markerFeature = new ol.Feature({
        geometry: new ol.geom.Point(ol.proj.transform(position, "EPSG:4326", "EPSG:3857"))
      })
      @markerFeature.setStyle(style)
    else
      @markerFeature.setGeometry(new ol.geom.Point(ol.proj.transform(position, "EPSG:4326", "EPSG:3857")))

    if !@markerLayer
      @markerLayer = new ol.layer.Vector({
        source: new ol.source.Vector({
          features: [@markerFeature]
        })
      })
      @map.addLayer(@markerLayer)

    @handlers['position'](position: position, zoom: @map.getView().getZoom(), event: 'updated') if @handlers['position']

  addMarker: (position, opts = {}) ->
    src = '/assets/img/map-marker.png'
    src = opts['image'] if opts['image']

    style = new ol.style.Style({
      image: new ol.style.Icon({
        anchor: [0.5, 1]
        anchorXUnits: 'fraction'
        anchorYUnits: 'fraction'
        src: src
      })
    })

    feature = new ol.Feature({
      geometry: new ol.geom.Point(ol.proj.transform(position, "EPSG:4326", "EPSG:3857"))
      name: opts['name']
      icon: opts['icon']
      date: opts['date']
      anpiState: opts['anpiState']
      anpiMessage: opts['anpiMessage']
      assemblageState: opts['assemblageState']
      assemblageMessage: opts['assemblageMessage']
      personFinderUri: opts['personFinderUri']
      registMember: opts['registMember']
    })
    feature.setStyle(style)

    layer = new ol.layer.Vector({
      source: new ol.source.Vector({
        features: [feature]
      })
    })

    @map.addLayer(layer)

  resetMarker: () ->
    if @markerLayer
      source = @markerLayer.getSource()
      source.forEachFeature (feature) ->
        source.removeFeature(feature)
      @map.removeLayer(@markerLayer)
      @markerFeature = null
      @markerLayer = null
    @handlers['position'](position: null, event: 'removed') if @handlers['position']

  setMarkerFromGps: () ->
    return unless navigator.geolocation
    navigator.geolocation.getCurrentPosition (position) =>
      @setMarker([position.coords.longitude, position.coords.latitude])

  on: (name, handler) ->
    @handlers[name] = handler
